from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from supabase import Client

from app.api.dependencies import get_db, get_optional_current_user
from app.db.supabase import get_supabase_admin
from app.schemas.sena import SenaResponse, CategoriaResumen, PosicionReferenciaResponse

router = APIRouter(prefix="/senas", tags=["Señas"])


@router.get("", response_model=List[SenaResponse])
async def listar_senas(
    categoria: Optional[str] = Query(None, description="Filtrar por categoría (ej: 'Alfabeto', 'Saludos')"),
    limite: int = Query(100, ge=1, le=500),
    offset: int = Query(0, ge=0),
):
    """
    Obtiene la lista de señas disponibles en el catálogo junto con sus datos de referencia.
    El catálogo es público para usuarios de la app.
    """
    admin_client = get_supabase_admin()
    query = admin_client.table("sena").select("*, posicion_referencia(*)").range(offset, offset + limite - 1)

    if categoria:
        query = query.eq("categoria", categoria)

    response = query.execute()

    # Mapear respuesta
    resultado = []
    for item in response.data:
        pos_data = item.get("posicion_referencia")
        posicion = None
        if pos_data:
            pos_obj = pos_data[0] if isinstance(pos_data, list) and pos_data else pos_data
            if isinstance(pos_obj, dict):
                posicion = PosicionReferenciaResponse(
                    sena_id=pos_obj.get("sena_id", item["id"]),
                    angulo_pulgar=pos_obj.get("angulo_pulgar", 0.0),
                    distancia_indice_medio=pos_obj.get("distancia_indice_medio", 0.0),
                    landmarks_clave=pos_obj.get("landmarks_clave", []),
                )

        resultado.append(
            SenaResponse(
                id=item["id"],
                nombre=item["nombre"],
                categoria=item["categoria"],
                descripcion=item["descripcion"],
                video_referencia=item.get("video_referencia"),
                creado_en=item.get("creado_en"),
                posicion_referencia=posicion,
            )
        )

    return resultado


@router.get("/categorias", response_model=List[CategoriaResumen])
async def obtener_categorias():
    """
    Retorna la lista de categorías únicas y la cantidad de señas en cada una.
    """
    admin_client = get_supabase_admin()
    response = admin_client.table("sena").select("categoria").execute()

    conteos: dict[str, int] = {}
    for item in response.data:
        cat = item["categoria"]
        conteos[cat] = conteos.get(cat, 0) + 1

    return [CategoriaResumen(categoria=cat, total_senas=count) for cat, count in conteos.items()]


@router.get("/{sena_id}", response_model=SenaResponse)
async def obtener_sena(sena_id: str):
    """
    Obtiene los detalles de una seña específica por su ID.
    """
    admin_client = get_supabase_admin()
    response = (
        admin_client.table("sena")
        .select("*, posicion_referencia(*)")
        .eq("id", sena_id)
        .limit(1)
        .execute()
    )

    if not response.data:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Seña con ID '{sena_id}' no encontrada.",
        )

    item = response.data[0]
    pos_data = item.get("posicion_referencia")
    posicion = None
    if pos_data:
        pos_obj = pos_data[0] if isinstance(pos_data, list) and pos_data else pos_data
        if isinstance(pos_obj, dict):
            posicion = PosicionReferenciaResponse(
                sena_id=pos_obj.get("sena_id", item["id"]),
                angulo_pulgar=pos_obj.get("angulo_pulgar", 0.0),
                distancia_indice_medio=pos_obj.get("distancia_indice_medio", 0.0),
                landmarks_clave=pos_obj.get("landmarks_clave", []),
            )

    return SenaResponse(
        id=item["id"],
        nombre=item["nombre"],
        categoria=item["categoria"],
        descripcion=item["descripcion"],
        video_referencia=item.get("video_referencia"),
        creado_en=item.get("creado_en"),
        posicion_referencia=posicion,
    )

