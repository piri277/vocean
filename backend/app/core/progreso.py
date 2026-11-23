from datetime import date
from typing import Optional

# Días distintos con al menos un acierto para dominar una seña.
DIAS_PARA_DOMINAR = 3


def siguiente_progreso(
    tipo: str,
    dias: int,
    ultimo_dia: Optional[date],
    hoy: date,
    acierto: bool,
) -> tuple[str, int, Optional[date]]:
    """Estado de una seña tras practicarla `hoy`: (tipo, dias, ultimo_dia).

    Abrir la práctica la pasa a 'en_practica'. Cada día distinto con un acierto
    suma uno a `dias` (varios aciertos el mismo día cuentan una vez) y al llegar
    a DIAS_PARA_DOMINAR queda 'dominada'.
    """
    if not acierto:
        if tipo in ("no_iniciada", "necesita_repaso"):
            return "en_practica", dias, ultimo_dia
        return tipo, dias, ultimo_dia
    if tipo == "dominada":
        return tipo, dias, ultimo_dia
    if ultimo_dia is None or hoy > ultimo_dia:
        dias, ultimo_dia = dias + 1, hoy
    return ("dominada" if dias >= DIAS_PARA_DOMINAR else "en_practica"), dias, ultimo_dia


# Experiencia (XP) que da el aprendizaje.
XP_PRACTICA = 10  # primer acierto del día en una seña
XP_DOMINAR = 30  # extra al dominarla

# Juego: XP por ganar cada dificultad, una sola vez por modo y dificultad.
XP_JUEGO = {"facil": 20, "medio": 30, "dificil": 40, "extremo": 50}
# Se gana con al menos el 75 % de aciertos.
ACIERTOS_PARA_GANAR = 0.75


# Reto diario: XP por ganarlo, una vez al día (5 preguntas, ganar con 4).
XP_RETO = 25


def xp_reto(aciertos: int, total: int) -> int:
    """XP del reto diario si se ganó; que sea el primero del día lo revisa la ruta."""
    if total <= 0 or aciertos / total < ACIERTOS_PARA_GANAR:
        return 0
    return XP_RETO


# Cultura: XP por aprobar el quiz de cada tema, una sola vez por tema.
XP_CULTURA = 15
TEMAS_CULTURA = ("linea-tiempo", "derechos", "lengua", "comunidad", "comunicacion", "curiosos", "mitos")


def xp_cultura(aciertos: int, total: int, ya_ganado: bool) -> int:
    """XP de un quiz de cultura: la primera vez que se aprueba ese tema."""
    if ya_ganado or total <= 0 or aciertos / total < ACIERTOS_PARA_GANAR:
        return 0
    return XP_CULTURA


def xp_practica(dias_previos: int, dias: int, recien_dominada: bool) -> int:
    """XP de una práctica: solo si sumó un día nuevo a la seña."""
    if dias <= dias_previos:
        return 0
    return XP_PRACTICA + (XP_DOMINAR if recien_dominada else 0)


def xp_juego(dificultad: str, aciertos: int, total: int, ya_ganado: bool) -> int:
    """XP de una partida: la primera victoria de ese modo y dificultad."""
    if ya_ganado or total <= 0 or aciertos / total < ACIERTOS_PARA_GANAR:
        return 0
    return XP_JUEGO[dificultad]
