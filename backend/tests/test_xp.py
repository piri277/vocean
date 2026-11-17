import unittest

from app.core.progreso import xp_juego, xp_practica


class XpPracticaTest(unittest.TestCase):
    def test_dia_nuevo_da_10(self):
        self.assertEqual(xp_practica(0, 1, False), 10)

    def test_mismo_dia_no_da(self):
        self.assertEqual(xp_practica(1, 1, False), 0)

    def test_dominar_suma_30(self):
        self.assertEqual(xp_practica(2, 3, True), 40)


class XpJuegoTest(unittest.TestCase):
    def test_victoria_da_xp_de_la_dificultad(self):
        self.assertEqual(xp_juego("dificil", 6, 8, False), 40)

    def test_derrota_no_da(self):
        self.assertEqual(xp_juego("facil", 5, 8, False), 0)

    def test_segunda_victoria_no_da(self):
        self.assertEqual(xp_juego("facil", 8, 8, True), 0)


if __name__ == "__main__":
    unittest.main()
