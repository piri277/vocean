from datetime import datetime, timezone
from typing import Any, Dict, Literal

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from supabase import Client

from app.api.dependencies import get_current_user, get_db, get_db_escritura
from app.core.progreso import xp_cultura
from app.schemas.usuario import UsuarioResponse

router = APIRouter(prefix="/cultura", tags=["Cultura"])


class ResultadoQuiz(BaseModel):
    """Resultado del quiz de un tema de cultura, para dar XP si se aprobó."""
    # Igual a TEMAS_CULTURA en app/core/progreso.py.
    tema: Literal["linea-tiempo", "derechos", "lengua", "comunidad", "comunicacion", "curiosos", "mitos"]
    aciertos: int = Field(ge=0)
    total: int = Field(ge=1, le=30)


@router.post("/quiz", response_model=UsuarioResponse)
async def registrar_quiz_cultura(
    datos: ResultadoQuiz,
    current_user: Dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
    admin: Client = Depends(get_db_escritura),
):
    """Da XP la primera vez que se aprueba el quiz de un tema. Devuelve el perfil."""
    if datos.aciertos > datos.total:
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="Los aciertos no pueden superar el total de preguntas.",
        )
    user_id = current_user["id"]
    usuario_res = db.table("usuario").select("*").eq("id", user_id).execute()
    if not usuario_res.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Perfil de usuario no encontrado.",
        )
    usr = usuario_res.data[0]
    ganados = usr.get("juegos_ganados") or []
    clave = f"cultura:{datos.tema}"
    xp = xp_cultura(datos.aciertos, datos.total, clave in ganados)
    if not xp:
        return usr

    res = admin.table("usuario").update({
        "xp_total": (usr.get("xp_total") or 0) + xp,
        "juegos_ganados": [*ganados, clave],
        "fecha_ultima_actividad": datetime.now(timezone.utc).isoformat(),
    }).eq("id", user_id).execute()
    if not res.data:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No se pudo registrar la XP del quiz.",
        )
    return res.data[0]
