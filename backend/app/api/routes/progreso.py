from datetime import datetime, timezone
from typing import Dict, Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client

from app.api.dependencies import get_current_user, get_db
from app.schemas.estado_aprendizaje import (
    EstadoAprendizajeResponse,
    EstadoAprendizajeUpdate,
    EstadoTipo,
)

router = APIRouter(prefix="/progreso", tags=["Progreso"])


@router.get("", response_model=List[EstadoAprendizajeResponse])
async def obtener_progreso_usuario(
    current_user: Dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Obtiene el estado de aprendizaje del usuario para todas las señas que ha interactuado.
    """
    user_id = current_user["id"]
    response = db.table("estado_aprendizaje").select("*").eq("usuario_id", user_id).execute()
    return response.data


@router.get("/{sena_id}", response_model=EstadoAprendizajeResponse)
async def obtener_progreso_sena(
    sena_id: str,
    current_user: Dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Obtiene el estado de aprendizaje del usuario para una seña específica.
    Si no existe aún, retorna un estado predeterminado 'no_iniciada'.
    """
    user_id = current_user["id"]
    response = (
        db.table("estado_aprendizaje")
        .select("*")
        .eq("usuario_id", user_id)
        .eq("sena_id", sena_id)
        .limit(1)
        .execute()
    )

    if response.data:
        return response.data[0]

    # Estado por defecto para señas que el usuario aún no ha tocado
    return EstadoAprendizajeResponse(
        usuario_id=user_id,
        sena_id=sena_id,
        tipo=EstadoTipo.no_iniciada,
        actualizado_en=datetime.now(timezone.utc),
    )


@router.put("/{sena_id}", response_model=EstadoAprendizajeResponse)
async def actualizar_progreso_sena(
    sena_id: str,
    datos: EstadoAprendizajeUpdate,
    current_user: Dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Crea o actualiza (upsert) el progreso de aprendizaje de una seña para el usuario autenticado.
    Verifica las reglas de negocio (ej. 'necesita_repaso' requiere 'motivo').
    """
    user_id = current_user["id"]

    # Validación adicional de existencia de la seña
    sena_check = db.table("sena").select("id").eq("id", sena_id).limit(1).execute()
    if not sena_check.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"La seña con ID '{sena_id}' no existe en el catálogo.",
        )

    registro = {
        "usuario_id": user_id,
        "sena_id": sena_id,
        "tipo": datos.tipo.value,
        "intentos": datos.intentos,
        "ultimo_intento": datos.ultimo_intento.isoformat() if datos.ultimo_intento else None,
        "fecha_dominada": datos.fecha_dominada.isoformat() if datos.fecha_dominada else None,
        "precision": datos.precision,
        "motivo": datos.motivo,
        "dias_sin_practicar": datos.dias_sin_practicar,
        "actualizado_en": datetime.now(timezone.utc).isoformat(),
    }

    try:
        response = db.table("estado_aprendizaje").upsert(registro).execute()
        if not response.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="No se pudo registrar el progreso en la base de datos.",
            )
        return response.data[0]
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Error al actualizar progreso: {str(e)}",
        )

