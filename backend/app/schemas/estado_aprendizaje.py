from datetime import datetime
from enum import Enum
from typing import Optional
from pydantic import BaseModel, Field, model_validator


class EstadoTipo(str, Enum):
    no_iniciada = "no_iniciada"
    en_practica = "en_practica"
    dominada = "dominada"
    necesita_repaso = "necesita_repaso"


class EstadoAprendizajeUpdate(BaseModel):
    tipo: EstadoTipo
    intentos: Optional[int] = Field(default=None, ge=0)
    ultimo_intento: Optional[datetime] = None
    fecha_dominada: Optional[datetime] = None
    precision: Optional[float] = Field(default=None, ge=0.0, le=1.0)
    motivo: Optional[str] = None
    dias_sin_practicar: Optional[int] = Field(default=None, ge=0)

    @model_validator(mode="after")
    def validate_rules(self) -> "EstadoAprendizajeUpdate":
        if self.tipo == EstadoTipo.necesita_repaso and not self.motivo:
            raise ValueError("El estado 'necesita_repaso' exige especificar un motivo.")
        return self


class EstadoAprendizajeResponse(BaseModel):
    usuario_id: str
    sena_id: str
    tipo: EstadoTipo
    intentos: Optional[int] = None
    ultimo_intento: Optional[datetime] = None
    fecha_dominada: Optional[datetime] = None
    precision: Optional[float] = None
    motivo: Optional[str] = None
    dias_sin_practicar: Optional[int] = None
    actualizado_en: datetime

