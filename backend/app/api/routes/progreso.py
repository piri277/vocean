from datetime import datetime, timezone
from typing import Dict, Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client

from app.api.dependencies import get_current_user, get_db, validar_fecha_local
from app.core.progreso import siguiente_progreso
from app.schemas.estado_aprendizaje import (
    EstadoAprendizajeResponse,
    EstadoAprendizajeUpdate,
    EstadoTipo,
    PracticaSenaRegistro,
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



@router.post("/{sena_id}/practica", response_model=EstadoAprendizajeResponse)
async def registrar_practica_sena(
    sena_id: str,
    datos: PracticaSenaRegistro,
    current_user: Dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Registra una práctica de la seña: abrirla la pasa a 'en_practica' y cada
    día distinto con un acierto la acerca a 'dominada' (ver app.core.progreso).
    `intentos` guarda los días con acierto y `ultimo_intento` el último de ellos.
    """
    validar_fecha_local(datos.fecha)
    user_id = current_user["id"]

    sena_check = db.table("sena").select("id").eq("id", sena_id).limit(1).execute()
    if not sena_check.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"La seña con ID '{sena_id}' no existe en el catálogo.",
        )

    actual_res = (
        db.table("estado_aprendizaje")
        .select("*")
        .eq("usuario_id", user_id)
        .eq("sena_id", sena_id)
        .limit(1)
        .execute()
    )
    actual = actual_res.data[0] if actual_res.data else {}
    ultimo = actual.get("ultimo_intento")
    tipo_previo = actual.get("tipo", EstadoTipo.no_iniciada.value)

    tipo, dias, ultimo_dia = siguiente_progreso(
        tipo_previo,
        actual.get("intentos") or 0,
        datetime.fromisoformat(ultimo).date() if ultimo else None,
        datos.fecha,
        datos.acierto,
    )

    ahora = datetime.now(timezone.utc).isoformat()
    recien_dominada = tipo == EstadoTipo.dominada.value and tipo_previo != tipo
    registro = {
        "usuario_id": user_id,
        "sena_id": sena_id,
        "tipo": tipo,
        "intentos": dias,
        "ultimo_intento": ultimo_dia.isoformat() if ultimo_dia else None,
        "fecha_dominada": ahora if recien_dominada else actual.get("fecha_dominada"),
        "precision": datos.precision if recien_dominada else actual.get("precision"),
        "motivo": None,
        "dias_sin_practicar": 0,
        "actualizado_en": ahora,
    }

    response = db.table("estado_aprendizaje").upsert(registro, on_conflict="usuario_id,sena_id").execute()
    if not response.data:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No se pudo registrar la práctica de la seña.",
        )
    return response.data[0]
