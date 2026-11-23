from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import health, senas, usuarios, progreso, partidas, cultura
from app.core.config import settings

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
app.include_router(cultura.router, prefix=settings.API_V1_STR)


@app.get("/", tags=["Root"])
async def root():
    return {
        "app": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "docs": "/docs",
        "health": f"{settings.API_V1_STR}/health",
    }

