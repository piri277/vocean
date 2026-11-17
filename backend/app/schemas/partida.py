from datetime import datetime
from enum import Enum
from typing import List, Literal, Optional
from pydantic import BaseModel, ConfigDict, Field, model_validator


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
    # Sin xp_ganado: la XP la decide el servidor en /partidas/resultado.
    model_config = ConfigDict(extra="forbid")
    dificultad: DificultadNivel
    puntuacion: int = Field(ge=0)
    racha_maxima: int = Field(ge=0)
    preguntas: List[PreguntaCreate] = Field(default_factory=list, max_length=50)

    @model_validator(mode="after")
    def _racha_cabe_en_la_partida(self):
        if self.racha_maxima > len(self.preguntas):
            raise ValueError("racha_maxima no puede superar el número de preguntas")
        return self


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
