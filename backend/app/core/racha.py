from datetime import date, timedelta
from typing import Optional


def calcular_racha(racha: int, ultima: Optional[date], hoy: date) -> int:
    """Racha tras practicar el día `hoy`.

    El mismo día no suma, el día siguiente suma uno y un hueco la reinicia a 1.
    Una fecha anterior a la última registrada no cambia nada.
    """
    if ultima is None:
        return 1
    if hoy <= ultima:
        return racha
    if hoy - ultima == timedelta(days=1):
        return racha + 1
    return 1
