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
