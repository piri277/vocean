from datetime import datetime
from typing import Optional, List
from pydantic import BaseModel, Field


class PosicionReferenciaBase(BaseModel):
    angulo_pulgar: float
    distancia_indice_medio: float
    landmarks_clave: List[int] = Field(default_factory=list)


class PosicionReferenciaResponse(PosicionReferenciaBase):
    sena_id: str


class SenaBase(BaseModel):
    id: str
    nombre: str
    categoria: str
    descripcion: str
    video_referencia: Optional[str] = None


class SenaCreate(SenaBase):
    pass


class SenaResponse(SenaBase):
    creado_en: Optional[datetime] = None
    posicion_referencia: Optional[PosicionReferenciaResponse] = None


class CategoriaResumen(BaseModel):
    categoria: str
    total_senas: int

