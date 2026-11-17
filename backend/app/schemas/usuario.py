from datetime import date, datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


class UsuarioBase(BaseModel):
    nombre: str


class UsuarioUpdate(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)
    # Sin espacios a los lados para que "   " no pase como nombre válido.
    nombre: Optional[str] = Field(default=None, min_length=2, max_length=40)
    xp_incremento: Optional[int] = Field(default=None, ge=0)
    incrementar_partida: Optional[bool] = False
    nueva_racha: Optional[int] = Field(default=None, ge=0)


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
    fecha_ultima_actividad: datetime
    creado_en: datetime



class PracticaRegistro(BaseModel):
    # Fecha local del dispositivo: el día cambia a medianoche del usuario, no en UTC.
    fecha: date
