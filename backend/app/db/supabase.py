from typing import Optional
# ClientOptions de `supabase` es la variante síncrona; la de supabase.lib es
# la base y create_client falla con ella ('no attribute storage').
from supabase import ClientOptions, create_client, Client
from app.core.config import settings

# Cliente con permisos administrativos (Service Role)
_admin_client: Optional[Client] = None


def get_supabase_admin() -> Client:
    """
    Retorna una instancia singleton del cliente Supabase con la Secret Key (Service Role).
    Utilizado para operaciones del sistema o administración interna.
    """
    global _admin_client
    if _admin_client is None:
        _admin_client = create_client(
            settings.SUPABASE_URL,
            settings.SUPABASE_SECRET_KEY,
        )
    return _admin_client


def get_user_supabase_client(access_token: Optional[str] = None) -> Client:
    """
    Crea un cliente Supabase con la Publishable Key y, opcionalmente,
    inyecta el JWT del usuario en la cabecera Authorization para respetar
    las políticas de Row Level Security (RLS) de PostgreSQL.
    """
    if access_token:
        options = ClientOptions(headers={"Authorization": f"Bearer {access_token}"})
        client = create_client(
            settings.SUPABASE_URL,
            settings.SUPABASE_PUBLISHABLE_KEY,
            options=options,
        )
        return client

    return create_client(settings.SUPABASE_URL, settings.SUPABASE_PUBLISHABLE_KEY)

