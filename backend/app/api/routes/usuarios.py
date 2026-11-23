from datetime import date, datetime, timezone
from typing import Dict, Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client

from app.api.dependencies import get_current_user, get_db, get_db_escritura, validar_fecha_local
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
    admin: Client = Depends(get_db_escritura),
):
    """
    Actualiza el nombre del usuario. Las estadísticas solo cambian por las
    rutas de práctica y juego, que las calculan en el servidor.
    """
    user_id = current_user["id"]
    perfil_actual_res = db.table("usuario").select("*").eq("id", user_id).execute()

    if not perfil_actual_res.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Perfil de usuario no encontrado.",
        )

    update_data: Dict[str, Any] = {
        "fecha_ultima_actividad": datetime.now(timezone.utc).isoformat(),
    }

    if datos.nombre is not None:
        update_data["nombre"] = datos.nombre.strip()

    res = admin.table("usuario").update(update_data).eq("id", user_id).execute()

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
    admin: Client = Depends(get_db_escritura),
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

    res = (
        admin.table("usuario")
        .update(campos_practica(actual_res.data[0], datos.fecha))
        .eq("id", user_id)
        .execute()
    )
    if not res.data:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al registrar la práctica.",
        )
    guardar_dia_practica(admin, user_id, datos.fecha)
    return res.data[0]


def campos_practica(usuario: Dict[str, Any], fecha: date) -> Dict[str, Any]:
    """Columnas de `usuario` a actualizar al practicar en `fecha` (racha incluida)."""
    ultima = usuario.get("ultima_practica")
    ultima_fecha = datetime.fromisoformat(ultima).date() if ultima else None
    return {
        "racha_dias": calcular_racha(usuario.get("racha_dias") or 0, ultima_fecha, fecha),
        "ultima_practica": max(fecha, ultima_fecha or fecha).isoformat(),
        "fecha_ultima_actividad": datetime.now(timezone.utc).isoformat(),
    }


def guardar_dia_practica(db: Client, user_id: str, fecha: date) -> None:
    """Historial para el calendario; si la tabla aún no existe, la racha sigue igual."""
    try:
        db.table("practica_dia").upsert(
            {"usuario_id": user_id, "fecha": fecha.isoformat()},
            on_conflict="usuario_id,fecha",
            ignore_duplicates=True,
        ).execute()
    except Exception as e:
        print(f"No se pudo guardar el día en practica_dia: {e}")


@router.get("/me/dias-practica", response_model=List[date])
async def listar_dias_practica(
    current_user: Dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """Fechas (locales) en que el usuario practicó, de la más antigua a la más reciente."""
    res = (
        db.table("practica_dia")
        .select("fecha")
        .eq("usuario_id", current_user["id"])
        .order("fecha")
        .execute()
    )
    return [fila["fecha"] for fila in res.data]
