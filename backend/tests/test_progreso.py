import unittest
from datetime import date

from app.core.progreso import siguiente_progreso

D1, D2, D3 = date(2026, 10, 24), date(2026, 10, 25), date(2026, 10, 26)


class SiguienteProgresoTest(unittest.TestCase):
    def test_abrir_practica_inicia(self):
        self.assertEqual(siguiente_progreso("no_iniciada", 0, None, D1, False), ("en_practica", 0, None))

    def test_abrir_practica_no_baja_una_dominada(self):
        self.assertEqual(siguiente_progreso("dominada", 3, D3, D3, False), ("dominada", 3, D3))

    def test_varios_aciertos_el_mismo_dia_cuentan_uno(self):
        estado = siguiente_progreso("en_practica", 0, None, D1, True)
        self.assertEqual(estado, ("en_practica", 1, D1))
        self.assertEqual(siguiente_progreso(*estado, D1, True), ("en_practica", 1, D1))

    def test_tres_dias_distintos_dominan(self):
        estado = ("en_practica", 0, None)
        for dia in (D1, D2, D3):
            estado = siguiente_progreso(*estado, dia, True)
        self.assertEqual(estado, ("dominada", 3, D3))


if __name__ == "__main__":
    unittest.main()
