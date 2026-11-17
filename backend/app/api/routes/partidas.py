from datetime import datetime, timezone
from typing import Dict, Any, List
from fastapi import APIRouter, Depends, HTTPException, status
from supabase import Client

from app.api.dependencies import get_current_user, get_db
from app.schemas.partida import (
    PartidaCreate,
    PartidaResponse,
    PreguntaResponse,
    VictoriaJuego,
)
from app.core.progreso import xp_juego
from app.schemas.usuario import UsuarioResponse

router = APIRouter(prefix="/partidas", tags=["Partidas y Juego"])


@router.post("", response_model=PartidaResponse, status_code=status.HTTP_201_CREATED)
async def registrar_partida(
    datos: PartidaCreate,
    current_user: Dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Registra una partida finalizada del juego "¿Qué está diciendo?",
    guarda las preguntas asociadas con su secuencia de señas y actualiza
    las partidas jugadas y la racha del usuario. No da XP: esa la calcula
    /partidas/resultado en el servidor.
    """
    user_id = current_user["id"]

    # 1. Guardar cabecera de la partida
    partida_payload = {
        "usuario_id": user_id,
        "dificultad": datos.dificultad.value,
        "puntuacion": datos.puntuacion,
        "racha_maxima": datos.racha_maxima,
        "xp_ganado": 0,
    }

    partida_res = db.table("partida").insert(partida_payload).execute()
    if not partida_res.data:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al crear el registro de la partida.",
        )

    partida_creada = partida_res.data[0]
    partida_id = partida_creada["id"]

    # 2. Guardar cada pregunta y su secuencia de señas
    preguntas_creadas: List[PreguntaResponse] = []
    for preg in datos.preguntas:
        pregunta_payload = {
            "partida_id": partida_id,
            "orden_en_partida": preg.orden_en_partida,
            "respuesta_correcta": preg.respuesta_correcta,
            "respuesta_usuario": preg.respuesta_usuario,
            "fue_correcta": preg.fue_correcta,
        }

        preg_res = db.table("pregunta").insert(pregunta_payload).execute()
        if preg_res.data:
            p_obj = preg_res.data[0]
            preguntas_creadas.append(
                PreguntaResponse(
                    id=p_obj["id"],
                    partida_id=p_obj["partida_id"],
                    orden_en_partida=p_obj["orden_en_partida"],
                    respuesta_correcta=p_obj["respuesta_correcta"],
                    respuesta_usuario=p_obj.get("respuesta_usuario"),
                    fue_correcta=p_obj.get("fue_correcta"),
                )
            )

            # Insertar secuencia de señas si aplica
            for orden, s_id in enumerate(preg.secuencia_senas_ids):
                db.table("pregunta_sena").insert({
                    "pregunta_id": p_obj["id"],
                    "sena_id": s_id,
                    "orden": orden,
                }).execute()

    # 3. Actualizar estadísticas globales del usuario
    usuario_res = db.table("usuario").select("*").eq("id", user_id).execute()
    if usuario_res.data:
        usr = usuario_res.data[0]
        db.table("usuario").update({
            "partidas_jugadas": usr.get("partidas_jugadas", 0) + 1,
            "racha_global_maxima": max(usr.get("racha_global_maxima", 0), datos.racha_maxima),
            "fecha_ultima_actividad": datetime.now(timezone.utc).isoformat(),
        }).eq("id", user_id).execute()

    return PartidaResponse(
        id=partida_creada["id"],
        usuario_id=partida_creada["usuario_id"],
        dificultad=partida_creada["dificultad"],
        puntuacion=partida_creada["puntuacion"],
        racha_maxima=partida_creada["racha_maxima"],
        xp_ganado=partida_creada["xp_ganado"],
        fecha=partida_creada["fecha"],
        preguntas=preguntas_creadas,
    )


@router.get("", response_model=List[PartidaResponse])
async def listar_partidas_usuario(
    limite: int = 20,
    current_user: Dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Obtiene el historial de partidas del usuario ordenadas de la más reciente a la más antigua.
    """
    user_id = current_user["id"]
    response = (
        db.table("partida")
        .select("*, pregunta(*)")
        .eq("usuario_id", user_id)
        .order("fecha", desc=True)
        .limit(limite)
        .execute()
    )

    partidas = []
    for item in response.data:
        pregs = [
            PreguntaResponse(
                id=p["id"],
                partida_id=p["partida_id"],
                orden_en_partida=p["orden_en_partida"],
                respuesta_correcta=p["respuesta_correcta"],
                respuesta_usuario=p.get("respuesta_usuario"),
                fue_correcta=p.get("fue_correcta"),
            )
            for p in item.get("pregunta", [])
        ]

        partidas.append(
            PartidaResponse(
                id=item["id"],
                usuario_id=item["usuario_id"],
                dificultad=item["dificultad"],
                puntuacion=item["puntuacion"],
                racha_maxima=item["racha_maxima"],
                xp_ganado=item["xp_ganado"],
                fecha=item["fecha"],
                preguntas=pregs,
            )
        )

    return partidas



@router.post("/resultado", response_model=UsuarioResponse)
async def registrar_resultado_juego(
    datos: VictoriaJuego,
    current_user: Dict[str, Any] = Depends(get_current_user),
    db: Client = Depends(get_db),
):
    """
    Da XP por ganar una partida, solo la primera vez en cada modo y dificultad.
    Devuelve el perfil; si no hubo XP queda igual.
    """
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
    clave = f"{datos.modo}:{datos.dificultad.value}"
    xp = xp_juego(datos.dificultad.value, datos.aciertos, datos.total, clave in ganados)
    if not xp:
        return usr

    res = db.table("usuario").update({
        "xp_total": (usr.get("xp_total") or 0) + xp,
        "juegos_ganados": [*ganados, clave],
        "fecha_ultima_actividad": datetime.now(timezone.utc).isoformat(),
    }).eq("id", user_id).execute()
    if not res.data:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="No se pudo registrar la XP del juego.",
        )
    return res.data[0]
