from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import health, senas, usuarios, progreso, partidas
from app.core.config import settings
from app.db.seed import poblar_catalogo

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="Backend API para Miapp — Aprendizaje y Práctica de Lengua de Señas con Supabase.",
    docs_url="/docs",
    redoc_url="/redoc",
)

# Configuración de CORS para permitir solicitudes desde la app Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Registro de rutas de la API bajo el prefijo configurado
app.include_router(health.router, prefix=settings.API_V1_STR)
app.include_router(senas.router, prefix=settings.API_V1_STR)
app.include_router(usuarios.router, prefix=settings.API_V1_STR)
app.include_router(progreso.router, prefix=settings.API_V1_STR)
app.include_router(partidas.router, prefix=settings.API_V1_STR)


@app.get("/", tags=["Root"])
async def root():
    return {
        "app": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "docs": "/docs",
        "health": f"{settings.API_V1_STR}/health",
    }


@app.post(f"{settings.API_V1_STR}/admin/seed", tags=["Admin"], status_code=status.HTTP_200_OK)
async def ejecutar_seed():
    """
    Endpoint administrativo para poblar o actualizar el catálogo de señas inicial en Supabase.
    """
    resultado = poblar_catalogo()
    return resultado

