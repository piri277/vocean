"""Pruebas de los hallazgos de seguridad H-02, H-03, H-04 y H-08 (evidencia en docs/evidencia/)."""
import asyncio
import unittest
from unittest import mock

from fastapi import HTTPException
from fastapi.security import HTTPAuthorizationCredentials
from pydantic import ValidationError

from app.api import dependencies
from app.main import app
from app.schemas.partida import PartidaCreate, PreguntaCreate
from app.schemas.usuario import UsuarioUpdate


class H02SeedSinAutenticacion(unittest.TestCase):
    def test_no_hay_endpoint_publico_de_seed(self):
        rutas = [getattr(r, "path", "") for r in app.routes]
        self.assertNotIn("/api/admin/seed", rutas)


class H03PerfilNoAceptaEstadisticas(unittest.TestCase):
    def test_rechaza_xp_enviada_por_el_cliente(self):
        with self.assertRaises(ValidationError):
            UsuarioUpdate(xp_incremento=999999)

    def test_rechaza_racha_enviada_por_el_cliente(self):
        with self.assertRaises(ValidationError):
            UsuarioUpdate(nueva_racha=999)

    def test_acepta_cambiar_nombre(self):
        self.assertEqual(UsuarioUpdate(nombre="Ana").nombre, "Ana")


class H04PartidaNoAceptaXp(unittest.TestCase):
    def test_rechaza_xp_enviada_por_el_cliente(self):
        with self.assertRaises(ValidationError):
            PartidaCreate(dificultad="facil", puntuacion=0, racha_maxima=0, xp_ganado=999999)

    def test_rechaza_racha_mayor_que_las_preguntas(self):
        with self.assertRaises(ValidationError):
            PartidaCreate(dificultad="facil", puntuacion=0, racha_maxima=50, preguntas=[])

    def test_acepta_partida_valida(self):
        p = PartidaCreate(
            dificultad="facil", puntuacion=1, racha_maxima=1,
            preguntas=[PreguntaCreate(orden_en_partida=1, respuesta_correcta="a")],
        )
        self.assertEqual(p.racha_maxima, 1)


class H08ErrorDeAuthNoFiltraDetalles(unittest.TestCase):
    def test_401_no_incluye_la_excepcion_interna(self):
        cliente = mock.Mock()
        cliente.auth.get_user.side_effect = Exception("detalle interno sb_secret_xxx")
        cred = HTTPAuthorizationCredentials(scheme="Bearer", credentials="token-falso")
        with mock.patch.object(dependencies, "get_supabase_admin", return_value=cliente):
            with self.assertRaises(HTTPException) as ctx:
                asyncio.run(dependencies.get_current_user(cred))
        self.assertEqual(ctx.exception.status_code, 401)
        self.assertNotIn("sb_secret", ctx.exception.detail)


if __name__ == "__main__":
    unittest.main()


class H09SoloElBackendEscribe(unittest.TestCase):
    """Las rutas escriben con la llave de servidor; el token del usuario solo lee."""

    def test_ninguna_ruta_escribe_con_el_cliente_del_usuario(self):
        import pathlib
        import re

        rutas = pathlib.Path(__file__).resolve().parents[1] / "app" / "api" / "routes"
        escritura = re.compile(r'\bdb\.table\("[a-z_]+"\)\s*\.(insert|update|upsert|delete)\(')
        for archivo in rutas.glob("*.py"):
            texto = archivo.read_text()
            # guardar_dia_practica recibe el cliente de escritura como `db`.
            texto = texto.split("def guardar_dia_practica")[0]
            self.assertIsNone(escritura.search(texto), archivo.name)
