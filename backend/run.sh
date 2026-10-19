#!/usr/bin/env bash
# Script para iniciar el servidor de desarrollo FastAPI

set -e

# Asegurar que estamos en el directorio del backend
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

if [ ! -d ".venv" ]; then
    echo "Creando entorno virtual en .venv..."
    python3 -m venv .venv
    .venv/bin/pip install -r requirements.txt
fi

echo "Iniciando Miapp API en http://localhost:8000 (Docs: http://localhost:8000/docs)..."
.venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

