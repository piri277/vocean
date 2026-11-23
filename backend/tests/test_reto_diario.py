import asyncio
import unittest
from datetime import date, datetime, timezone

from app.api.routes.partidas import registrar_reto_diario, registrar_supervivencia
from app.core.progreso import xp_reto
from app.schemas.partida import ResultadoReto, ResultadoSupervivencia


class _Consulta:
    def __init__(self, db, tabla):
        self.db, self.tabla, self.cambios = db, tabla, None

    def select(self, *_):
        return self

    def update(self, cambios):
        self.cambios = cambios
        return self

    def upsert(self, fila, **_):
        self.db.dias.append(fila["fecha"])
        return self

    def eq(self, *_):
        return self

    def execute(self):
        if self.tabla == "practica_dia":
            return type("R", (), {"data": []})()
        if self.cambios is not None:
            self.db.usuario.update(self.cambios)
        return type("R", (), {"data": [dict(self.db.usuario)]})()


class _Db:
    def __init__(self, usuario):
        self.usuario, self.dias = usuario, []

    def table(self, nombre):
        return _Consulta(self, nombre)


def _hoy():
    return datetime.now(timezone.utc).date()


def _jugar(db, aciertos):
    datos = ResultadoReto(fecha=_hoy(), aciertos=aciertos, total=5)
    return asyncio.run(registrar_reto_diario(datos, {"id": "u1"}, db, db))


class RetoDiarioTest(unittest.TestCase):
    def test_xp_solo_si_gana(self):
        self.assertEqual(xp_reto(4, 5), 25)
        self.assertEqual(xp_reto(3, 5), 0)

    def test_ganar_da_xp_y_suma_racha(self):
        db = _Db({"xp_total": 0, "racha_dias": 0, "ultima_practica": None, "juegos_ganados": ["reto:2020-01-01", "facil:medio"]})
        usr = _jugar(db, 5)
        self.assertEqual(usr["xp_total"], 25)
        self.assertEqual(usr["racha_dias"], 1)
        # El reto viejo se borra; las demás claves se quedan.
        self.assertEqual(usr["juegos_ganados"], ["facil:medio", f"reto:{_hoy().isoformat()}"])
        self.assertEqual(db.dias, [_hoy().isoformat()])

    def test_segunda_partida_del_dia_no_cambia_nada(self):
        db = _Db({"xp_total": 0, "racha_dias": 0, "ultima_practica": None, "juegos_ganados": []})
        _jugar(db, 5)
        usr = _jugar(db, 5)
        self.assertEqual(usr["xp_total"], 25)

    def test_sin_aciertos_no_cuenta_como_practica(self):
        db = _Db({"xp_total": 0, "racha_dias": 0, "ultima_practica": None, "juegos_ganados": []})
        usr = _jugar(db, 0)
        self.assertEqual(usr["racha_dias"], 0)
        self.assertEqual(db.dias, [])

    def test_rechaza_fecha_que_no_es_hoy(self):
        from fastapi import HTTPException
        db = _Db({"juegos_ganados": []})
        datos = ResultadoReto(fecha=date(2020, 1, 1), aciertos=5, total=5)
        with self.assertRaises(HTTPException):
            asyncio.run(registrar_reto_diario(datos, {"id": "u1"}, db, db))


class RecordSupervivenciaTest(unittest.TestCase):
    def _jugar(self, db, aciertos):
        datos = ResultadoSupervivencia(aciertos=aciertos)
        return asyncio.run(registrar_supervivencia(datos, {"id": "u1"}, db, db))

    def test_guarda_solo_si_supera_el_record(self):
        db = _Db({"record_supervivencia": 7})
        self.assertEqual(self._jugar(db, 5)["record_supervivencia"], 7)
        self.assertEqual(self._jugar(db, 12)["record_supervivencia"], 12)

    def test_sin_record_previo(self):
        db = _Db({"record_supervivencia": None})
        self.assertEqual(self._jugar(db, 3)["record_supervivencia"], 3)


if __name__ == "__main__":
    unittest.main()
