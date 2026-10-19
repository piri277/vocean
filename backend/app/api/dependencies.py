from typing import Optional, Dict, Any
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from supabase import Client

from app.db.supabase import get_supabase_admin, get_user_supabase_client

# Esquema Bearer opcional y obligatorio
bearer_scheme = HTTPBearer(auto_error=True)
optional_bearer_scheme = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
) -> Dict[str, Any]:
    """
    Extrae y valida el JWT emitido por Supabase Auth.
    Retorna el diccionario con la información del usuario autenticado.
    """
    token = credentials.credentials
    admin_client = get_supabase_admin()

    try:
        user_response = admin_client.auth.get_user(token)
        if not user_response or not user_response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token de autenticación inválido o expirado.",
                headers={"WWW-Authenticate": "Bearer"},
            )
        user = user_response.user
        return {
            "id": user.id,
            "email": user.email,
            "token": token,
            "metadata": user.user_metadata or {},
        }
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Error al verificar credenciales: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )


async def get_optional_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(optional_bearer_scheme),
) -> Optional[Dict[str, Any]]:
    """
    Permite acceso opcional: si se provee token, lo valida; si no, retorna None.
    """
    if not credentials:
        return None
    try:
        return await get_current_user(credentials)
    except HTTPException:
        return None


def get_db(current_user: Dict[str, Any] = Depends(get_current_user)) -> Client:
    """
    Retorna un cliente Supabase con el JWT del usuario inyectado
    para que PostgreSQL aplique las reglas de Row Level Security (RLS).
    """
    return get_user_supabase_client(access_token=current_user["token"])

