from datetime import datetime
from enum import Enum
from typing import List, Literal, Optional
from pydantic import BaseModel, Field


class DificultadNivel(str, Enum):
    facil = "facil"
    medio = "medio"
    dificil = "dificil"
    extremo = "extremo"


class PreguntaCreate(BaseModel):
    orden_en_partida: int
    respuesta_correcta: str
    respuesta_usuario: Optional[str] = None
    fue_correcta: Optional[bool] = None
    secuencia_senas_ids: List[str] = Field(default_factory=list)


class PreguntaResponse(BaseModel):
    id: str
    partida_id: str
    orden_en_partida: int
    respuesta_correcta: str
    respuesta_usuario: Optional[str] = None
    fue_correcta: Optional[bool] = None


class PartidaCreate(BaseModel):
    dificultad: DificultadNivel
    puntuacion: int = Field(ge=0)
    racha_maxima: int = Field(ge=0)
    xp_ganado: int = Field(ge=0)
    preguntas: List[PreguntaCreate] = Field(default_factory=list)


class PartidaResponse(BaseModel):
    id: str
    usuario_id: str
    dificultad: DificultadNivel
    puntuacion: int
    racha_maxima: int
    xp_ganado: int
    fecha: datetime
    preguntas: Optional[List[PreguntaResponse]] = None



class VictoriaJuego(BaseModel):
    """Resultado de una partida del juego, para dar XP si se ganó."""
    modo: Literal["palabras", "numeros", "mezcla"]
    dificultad: DificultadNivel
    aciertos: int = Field(ge=0)
    total: int = Field(ge=1, le=50)
