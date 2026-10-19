"""
Script para poblar (seed) la base de datos de Supabase con el catálogo inicial de señas
y sus posiciones de referencia anatómicas para validación.
"""

from typing import List, Dict, Any
from app.db.supabase import get_supabase_admin

CATALOGO_SEMILLA: List[Dict[str, Any]] = [
    {
        "id": "alfa-a",
        "nombre": "Letra A",
        "categoria": "Alfabeto",
        "descripcion": "Cierra el puño con el pulgar al costado. Los cuatro dedos deben estar juntos y doblados hacia la palma, con el pulgar descansando al lado del índice.",
        "posicion": {
            "landmarks_clave": [0, 5, 8, 12, 16, 20],
            "angulo_pulgar": 26.0,
            "distancia_indice_medio": 0.45,
        },
    },
    {
        "id": "alfa-b",
        "nombre": "Letra B",
        "categoria": "Alfabeto",
        "descripcion": "Levanta los cuatro dedos juntos y rectos hacia arriba. El pulgar se cruza sobre la palma, tocando la base de los dedos.",
        "posicion": {
            "landmarks_clave": [0, 4, 8, 12, 16, 20],
            "angulo_pulgar": 40.0,
            "distancia_indice_medio": 0.62,
        },
    },
    {
        "id": "alfa-c",
        "nombre": "Letra C",
        "categoria": "Alfabeto",
        "descripcion": "Curva todos los dedos y el pulgar formando la forma de la letra C. La mano debe parecer que está sosteniendo un vaso imaginario.",
        "posicion": {
            "landmarks_clave": [0, 8, 12, 16, 20],
            "angulo_pulgar": 18.0,
            "distancia_indice_medio": 0.38,
        },
    },
    {
        "id": "sal-1",
        "nombre": "Hola",
        "categoria": "Saludos",
        "descripcion": "Levanta la mano abierta a la altura de la cara y muévela de lado a lado. Todos los dedos deben estar extendidos y juntos.",
        "posicion": {
            "landmarks_clave": [0, 5, 8, 12, 16, 20],
            "angulo_pulgar": 15.0,
            "distancia_indice_medio": 0.82,
        },
    },
    {
        "id": "sal-2",
        "nombre": "Gracias",
        "categoria": "Saludos",
        "descripcion": "El pulgar y el índice se tocan formando una pequeña pinza, mientras el resto de los dedos se mantienen suaves y relajados.",
        "posicion": {
            "landmarks_clave": [0, 4, 8, 12, 16],
            "angulo_pulgar": 32.0,
            "distancia_indice_medio": 0.54,
        },
    },
    {
        "id": "sal-3",
        "nombre": "Por favor",
        "categoria": "Saludos",
        "descripcion": "La mano se coloca frente al pecho con la palma hacia abajo y los dedos ligeramente curvados en un movimiento de gesto amable.",
        "posicion": {
            "landmarks_clave": [0, 5, 8, 12, 16],
            "angulo_pulgar": 24.0,
            "distancia_indice_medio": 0.58,
        },
    },
    {
        "id": "num-1",
        "nombre": "Número 1",
        "categoria": "Números",
        "descripcion": "Levanta únicamente el dedo índice, manteniendo el resto de los dedos cerrados en puño y el pulgar apoyado suavemente sobre la palma.",
        "posicion": {
            "landmarks_clave": [0, 5, 8, 12, 16, 20],
            "angulo_pulgar": 52.0,
            "distancia_indice_medio": 0.58,
        },
    },
    {
        "id": "num-2",
        "nombre": "Número 2",
        "categoria": "Números",
        "descripcion": "Levanta el dedo índice y el dedo medio juntos, separados del resto. Los demás dedos se cierran en puño con el pulgar sobre ellos.",
        "posicion": {
            "landmarks_clave": [0, 5, 8, 12, 16, 20],
            "angulo_pulgar": 48.0,
            "distancia_indice_medio": 0.70,
        },
    },
    {
        "id": "num-3",
        "nombre": "Número 3",
        "categoria": "Números",
        "descripcion": "Levanta el pulgar, el índice y el medio. El anular y el meñique se cierran hacia la palma, como contar hasta tres con la mano.",
        "posicion": {
            "landmarks_clave": [0, 4, 8, 12, 16, 20],
            "angulo_pulgar": 60.0,
            "distancia_indice_medio": 0.80,
        },
    },
    {
        "id": "emer-1",
        "nombre": "Ayuda",
        "categoria": "Emergencias",
        "descripcion": "Cierra el puño con el pulgar levantado y colócalo sobre la palma de la otra mano abierta. Mueve ambas manos hacia arriba.",
        "posicion": {
            "landmarks_clave": [0, 5, 8, 12, 16],
            "angulo_pulgar": 70.0,
            "distancia_indice_medio": 0.40,
        },
    },
    {
        "id": "emer-2",
        "nombre": "Emergencia",
        "categoria": "Emergencias",
        "descripcion": "Extiende todos los dedos y apoya la mano abierta en una posición firme, indicando alerta y atención inmediata.",
        "posicion": {
            "landmarks_clave": [0, 5, 8, 12, 16, 20],
            "angulo_pulgar": 12.0,
            "distancia_indice_medio": 0.90,
        },
    },
    {
        "id": "emer-3",
        "nombre": "Urgente",
        "categoria": "Emergencias",
        "descripcion": "Señala con el dedo índice hacia adelante y mantiene la otra mano cerrada con atención inmediata para avisar de peligro.",
        "posicion": {
            "landmarks_clave": [0, 5, 8, 12, 16],
            "angulo_pulgar": 35.0,
            "distancia_indice_medio": 0.75,
        },
    },
]


def poblar_catalogo() -> Dict[str, Any]:
    """
    Inserta o actualiza las señas y posiciones de referencia en Supabase.
    """
    admin = get_supabase_admin()
    insertadas = 0

    for item in CATALOGO_SEMILLA:
        sena_data = {
            "id": item["id"],
            "nombre": item["nombre"],
            "categoria": item["categoria"],
            "descripcion": item["descripcion"],
            "video_referencia": item.get("video_referencia"),
        }
        # Upsert en sena
        admin.table("sena").upsert(sena_data).execute()

        # Upsert en posicion_referencia
        pos = item["posicion"]
        pos_data = {
            "sena_id": item["id"],
            "angulo_pulgar": pos["angulo_pulgar"],
            "distancia_indice_medio": pos["distancia_indice_medio"],
            "landmarks_clave": pos["landmarks_clave"],
        }
        admin.table("posicion_referencia").upsert(pos_data).execute()
        insertadas += 1

    return {"status": "ok", "total_procesadas": insertadas}


if __name__ == "__main__":
    resultado = poblar_catalogo()
    print(f"Catálogo poblado con éxito: {resultado}")

