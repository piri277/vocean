from fastapi import APIRouter, status
from fastapi.responses import JSONResponse
from app.core.config import settings
from app.db.supabase import get_supabase_admin

router = APIRouter(prefix="/health", tags=["Health"])


@router.get("", status_code=status.HTTP_200_OK)
async def health_check():
    """
    Verifica el estado del servicio y la conexión a la base de datos de Supabase.
    """
    supabase_status = "unknown"
    error_detail = None

    try:
        admin_client = get_supabase_admin()
        # Prueba de conectividad ligera consultando la tabla sena
        response = admin_client.table("sena").select("id").limit(1).execute()
        supabase_status = "connected"
    except Exception as e:
        supabase_status = "disconnected"
        error_detail = str(e)

    http_status = status.HTTP_200_OK if supabase_status == "connected" else status.HTTP_503_SERVICE_UNAVAILABLE

    return JSONResponse(
        status_code=http_status,
        content={
            "app": settings.PROJECT_NAME,
            "version": settings.VERSION,
            "status": "ok" if supabase_status == "connected" else "degraded",
            "supabase": {
                "url": settings.SUPABASE_URL,
                "status": supabase_status,
                "error": error_detail,
            },
        },
    )

