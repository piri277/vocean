from datetime import date, datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field


class UsuarioBase(BaseModel):
    nombre: str


class UsuarioUpdate(BaseModel):
    # extra="forbid": XP, partidas y racha los calcula el servidor; si el cliente
    # los manda, la petición se rechaza en vez de ignorarlos en silencio.
    model_config = ConfigDict(str_strip_whitespace=True, extra="forbid")
    # Sin espacios a los lados para que "   " no pase como nombre válido.
    nombre: Optional[str] = Field(default=None, min_length=2, max_length=40)


class UsuarioResponse(BaseModel):
    id: str
    nombre: str
    correo: Optional[str] = None
    xp_total: int
    partidas_jugadas: int
    racha_global_maxima: int
    # Con default para no romper antes de aplicar migracion_racha_dias.sql.
    racha_dias: int = 0
    ultima_practica: Optional[date] = None
    # Claves "modo:dificultad" y "cultura:tema" ya premiadas con XP.
    juegos_ganados: Optional[List[str]] = None
    record_supervivencia: int = 0
    fecha_ultima_actividad: datetime
    creado_en: datetime



class PracticaRegistro(BaseModel):
    # Fecha local del dispositivo: el día cambia a medianoche del usuario, no en UTC.
    fecha: date
