from datetime import datetime
from typing import Optional
from pydantic import BaseModel, Field


class UsuarioBase(BaseModel):
    nombre: str


class UsuarioUpdate(BaseModel):
    nombre: Optional[str] = None
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
    fecha_ultima_actividad: datetime
    creado_en: datetime

