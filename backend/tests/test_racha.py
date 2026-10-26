import unittest
from datetime import date

from app.core.racha import calcular_racha

HOY = date(2026, 10, 26)


class CalcularRachaTest(unittest.TestCase):
    def test_primera_practica(self):
        self.assertEqual(calcular_racha(0, None, HOY), 1)

    def test_mismo_dia_no_suma(self):
        self.assertEqual(calcular_racha(3, HOY, HOY), 3)

    def test_dia_siguiente_suma(self):
        self.assertEqual(calcular_racha(3, date(2026, 10, 25), HOY), 4)

    def test_hueco_reinicia(self):
        self.assertEqual(calcular_racha(3, date(2026, 10, 23), HOY), 1)

    def test_fecha_anterior_no_cambia(self):
        self.assertEqual(calcular_racha(3, date(2026, 10, 27), HOY), 3)


if __name__ == "__main__":
    unittest.main()
