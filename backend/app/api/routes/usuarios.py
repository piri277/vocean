from datetime import datetime, timezone
from typing import Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client

from app.api.dependencies import get_current_user, get_db, validar_fecha_local
from app.db.supabase import get_supabase_admin
from app.core.racha import calcular_racha
from app.schemas.usuario import PracticaRegistro, UsuarioResponse, UsuarioUpdate

router = APIRouter(prefix="/usuarios", tags=["Usuarios"])


@router.get("/me", response_model=UsuarioResponse)
async def obtener_perfil_actual(
    current_user: Dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Obtiene los datos del perfil y estadísticas del usuario autenticado.
    Si no existe la fila por haber sido creado previo al trigger de Supabase,
    se aprovisiona automáticamente.
    """
    user_id = current_user["id"]
    response = db.table("usuario").select("*").eq("id", user_id).execute()

    if not response.data:
        # Aprovisionamiento de respaldo si el trigger no corrió
        admin_client = get_supabase_admin()
        nombre = (
            current_user.get("metadata", {}).get("nombre")
            or current_user.get("email", "").split("@")[0]
            or "Usuario"
        )
        insert_res = admin_client.table("usuario").insert({
            "id": user_id,
            "nombre": nombre,
            "correo": current_user.get("email"),
        }).execute()
        if not insert_res.data:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="No se pudo inicializar el perfil de usuario.",
            )
        return insert_res.data[0]

    return response.data[0]


@router.patch("/me", response_model=UsuarioResponse)
async def actualizar_perfil(
    datos: UsuarioUpdate,
    current_user: Dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Actualiza datos del perfil del usuario (nombre o estadísticas acumuladas).
    """
    user_id = current_user["id"]
    perfil_actual_res = db.table("usuario").select("*").eq("id", user_id).execute()

    if not perfil_actual_res.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Perfil de usuario no encontrado.",
        )

    actual = perfil_actual_res.data[0]
    update_data: Dict[str, Any] = {
        "fecha_ultima_actividad": datetime.now(timezone.utc).isoformat(),
    }

    if datos.nombre is not None:
        update_data["nombre"] = datos.nombre.strip()

    if datos.xp_incremento is not None:
        update_data["xp_total"] = actual.get("xp_total", 0) + datos.xp_incremento

    if datos.incrementar_partida:
        update_data["partidas_jugadas"] = actual.get("partidas_jugadas", 0) + 1

    if datos.nueva_racha is not None:
        racha_actual = actual.get("racha_global_maxima", 0)
        update_data["racha_global_maxima"] = max(racha_actual, datos.nueva_racha)

    res = db.table("usuario").update(update_data).eq("id", user_id).execute()

    if not res.data:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al actualizar el perfil en la base de datos.",
        )

    return res.data[0]



@router.post("/me/practica", response_model=UsuarioResponse)
async def registrar_practica(
    datos: PracticaRegistro,
    current_user: Dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Registra que el usuario practicó en `datos.fecha` y actualiza su racha de días.
    Practicar varias veces el mismo día no suma.
    """
    validar_fecha_local(datos.fecha)

    user_id = current_user["id"]
    actual_res = db.table("usuario").select("*").eq("id", user_id).execute()
    if not actual_res.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Perfil de usuario no encontrado.",
        )

    actual = actual_res.data[0]
    ultima = actual.get("ultima_practica")
    ultima_fecha = datetime.fromisoformat(ultima).date() if ultima else None
    racha = calcular_racha(actual.get("racha_dias") or 0, ultima_fecha, datos.fecha)

    res = (
        db.table("usuario")
        .update({
            "racha_dias": racha,
            "ultima_practica": max(datos.fecha, ultima_fecha or datos.fecha).isoformat(),
            "fecha_ultima_actividad": datetime.now(timezone.utc).isoformat(),
        })
        .eq("id", user_id)
        .execute()
    )
    if not res.data:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al registrar la práctica.",
        )
    return res.data[0]
