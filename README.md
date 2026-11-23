# VOCEAN — Aprende Lengua de Señas Colombiana con tu cámara

App móvil (Android, Flutter) para aprender vocabulario básico de la **Lengua de Señas Colombiana (LSC)**. Muestra cómo se hace cada seña, la practicas frente a la cámara del teléfono y recibes retroalimentación al instante.

> VOCEAN es una herramienta educativa de práctica. No es un traductor de LSC y no entiende frases ni conversaciones.

## Funciones

| Pestaña | Qué hace |
|---|---|
| **Diccionario** | Progreso general, señas por categoría (Alfabeto, Números, Saludos, Emergencias), buscador y filtros por estado. Cada seña tiene imagen de referencia e instrucciones. |
| **Práctica** | Se abre desde el detalle de una seña. Usa la cámara, detecta la mano y compara la pose con la referencia. Al acertar un día distinto suma a la seña hacia «dominada» y a la racha. |
| **Juego** | «¿Qué está diciendo?»: adivina la palabra o número formado por señas. Modos Palabras, Números y Mezcla; dificultades Fácil, Medio, Difícil y Extremo. |
| **Cultura** | Historia de la comunidad sorda, datos de la LSC y un dato del día. |
| **Perfil** | Nivel y XP, racha actual con calendario, estadísticas, progreso de aprendizaje, cambio de nombre y contraseña, cerrar sesión. |

### Racha, XP y dominio

- **Racha:** días seguidos con al menos un acierto. Se pierde si no practicas ni hoy ni ayer. Al perderla aparece el aviso «Perdiste tu racha» (una vez por racha).
- **Dominar una seña:** acertarla en **3 días distintos**.
- **XP por práctica:** +10 la primera vez al día que aciertas una seña; +30 extra al dominarla.
- **XP por juego:** ganas con al menos 75 % de aciertos. Se da XP solo la primera vez en cada modo y dificultad:

| Dificultad | XP |
|---|---|
| Fácil | 20 |
| Medio | 30 |
| Difícil | 40 |
| Extremo | 50 |

- **Nivel:** cada 100 XP sube un nivel.

Las reglas están en `backend/app/core/progreso.py` (`XP_PRACTICA`, `XP_DOMINAR`, `XP_JUEGO`, `DIAS_PARA_DOMINAR`) y `backend/app/core/racha.py`. Los valores de XP por dificultad también aparecen en `lib/features/juego/views/juego_view.dart` (`_xpDificultad`); si cambias uno, cambia el otro.

## Arquitectura

```
lib/        app Flutter (Riverpod + go_router)
  core/       tema (paleta), red (ApiClient), router, widgets compartidos
  features/   auth, home, senas, juego, cultura, perfil
backend/    API FastAPI (Python)
  app/api/routes/   endpoints
  app/core/         reglas de negocio (progreso, racha, XP)
  app/db/           cliente de Supabase y carga del catálogo
  tests/            pruebas unitarias del backend
```

- **Autenticación y base de datos:** Supabase. La app inicia sesión directamente con Supabase Auth. Todo lo demás (progreso, racha, XP, partidas) pasa por el backend; la app nunca escribe en Postgres directamente.
- **Token:** la app envía el JWT de la sesión en `Authorization: Bearer`. El backend lo valida con Supabase antes de cada operación.
- **Paleta:** crema `#EEE2CB` (fondo, 60 %), verde abeto `#1B4532` (principal, 30 %) y rojo tomate `#EE4129` (acentos, 10 %). Está definida en `lib/core/theme/app_theme.dart`.

### Endpoints principales (prefijo `/api`)

| Método | Ruta | Uso |
|---|---|---|
| GET | `/health` | Estado del servidor |
| GET | `/senas` | Catálogo de señas (público) |
| GET | `/usuarios/me` | Perfil, XP, racha |
| PATCH | `/usuarios/me` | Cambiar nombre |
| POST | `/usuarios/me/practica` | Registrar práctica del día |
| GET | `/usuarios/me/dias-practica` | Días practicados (calendario) |
| GET / PUT / POST | `/progreso/{sena_id}` · `/progreso/{sena_id}/practica` | Estado de aprendizaje de una seña y registro de práctica |
| POST | `/partidas` | Guardar una partida |
| POST | `/partidas/resultado` | XP por ganar el juego |

Documentación interactiva con el servidor corriendo: `http://localhost:8000/docs`.

## Requisitos

- Flutter (Dart SDK compatible con `pubspec.yaml`)
- Python 3.12
- Un proyecto de Supabase con Auth activo
- Android con depuración USB, o un emulador

## Configuración

### Backend

Crea `backend/.env` (no se sube a git):

```
SUPABASE_URL=https://<tu-proyecto>.supabase.co
SUPABASE_PUBLISHABLE_KEY=<clave publicable>
SUPABASE_SECRET_KEY=<clave secreta; solo en el servidor>
SUPABASE_JWKS_URL=<opcional>
```

Crea las tablas y columnas de la base de datos en Supabase antes de correr el backend. Los cambios son: columnas `racha_dias`, `ultima_practica`, `juegos_ganados` en `usuario`, la tabla `practica_dia` (historial para el calendario) y las tablas del catálogo de señas.

### App

La app apunta por defecto a `http://localhost:8000/api`. Para otra URL:

```bash
flutter run --dart-define=API_URL=http://<IP-del-PC>:8000/api
```

En release la URL debe ser `https`.

## Cómo correrlo

**1. Backend** (terminal 1):

```bash
cd backend
./run.sh
```

Crea el entorno virtual `.venv` la primera vez y levanta la API en `http://localhost:8000`.

**2. Cargar el catálogo de señas** (una vez, o al cambiar el catálogo):

```bash
cd backend
.venv/bin/python -m app.db.seed
```

**3. Teléfono por USB** (terminal 2), para que `localhost:8000` del teléfono llegue al PC:

```bash
adb reverse tcp:8000 tcp:8000
```

Repítelo cada vez que reconectes el teléfono.

**4. App** (terminal 2):

```bash
flutter pub get
flutter run
```

## Pruebas

```bash
# App
flutter test
flutter analyze

# Backend
cd backend
.venv/bin/python -m unittest discover tests
```

Las pruebas del backend cubren las reglas de progreso, racha, XP y los hallazgos de seguridad de `docs/evidencia/`.

## Documentación adicional

- `proyecto.md`: especificación del producto (alcance del MVP, usuarios, requisitos).
- `docs/evidencia/`: evidencia de la revisión de seguridad y de los builds.
- `promo/`: video promocional.

## Solución de problemas

- **401 en todas las peticiones:** la sesión guardada venció. Cierra sesión y vuelve a entrar.
- **500 en `/api/senas`, o `Name or service not known` en el log del backend:** el backend no llega a Supabase. Revisa que `SUPABASE_URL` sea correcta y que el proyecto no esté pausado.
- **La app no conecta en el teléfono:** revisa `adb reverse tcp:8000 tcp:8000` y que el backend esté corriendo.
