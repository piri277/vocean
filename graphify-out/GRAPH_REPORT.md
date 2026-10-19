# Graph Report - miapp  (2026-10-18)

## Corpus Check
- Corpus is ~30,322 words - fits in a single context window. You may not need a graph.

## Summary
- 899 nodes · 1261 edges · 63 communities (52 shown, 11 thin omitted)
- Extraction: 96% EXTRACTED · 4% INFERRED · 0% AMBIGUOUS · INFERRED: 45 edges (avg confidence: 0.87)
- Token cost: 60,325 input · 0 output

## Community Hubs (Navigation)
- Auth Service & Providers
- iOS/macOS App Delegates
- Game Match Models
- Linux GTK Runner
- Hand Landmark Models
- Camera Detection Service
- Custom Painters & Questions
- Backend Config & Seed
- Windows Runner Entry
- Project Dependencies & CI
- Backend Progress API
- Senas Providers
- Learning State Model
- Backend Matches API
- Home & Category Views
- Sena Entity Model
- Win32 Window Lifecycle
- Backend Senas API
- Practice State
- Register Page
- Senas Repository Layer
- Backend Users API
- Practice Provider
- Home Bottom Navigation
- JSON Parsing Utils
- Local Senas Service
- Dictionary View
- Backend Auth Dependencies
- Profile & Progress Ring
- Hand Position Validator
- Login Page
- Windows Plugin Registry
- Auth & Practice Notifiers
- Windows Flutter Window
- App Theme
- Sena Chip Widget
- Windows Generated Plugins
- Web Manifest
- Shared UI Widgets
- Matches Repository
- Game View
- Practice View
- Win32 Message Handling
- Stateful Auth Pages
- Widget & Domain Tests
- Route Names
- Auth-Gated Views
- Exception Types
- App Router
- App Entry Point
- Desktop CMake Builds
- Supabase Config
- Sena Detail View
- Win32 Point
- Win32 Size
- Android Main Activity
- Backend Run Script

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 21 edges
2. `get_supabase_admin()` - 15 edges
3. `miapp Flutter package (pubspec)` - 11 edges
4. `FlutterWindow` - 10 edges
5. `get_current_user()` - 9 edges
6. `get_db()` - 9 edges
7. `authNotifierProvider` - 9 edges
8. `AuthState` - 9 edges
9. `registrar_partida()` - 8 edges
10. `listar_partidas_usuario()` - 7 edges

## Surprising Connections (you probably didn't know these)
- `supabase (Python client)` --semantically_similar_to--> `supabase_flutter`  [INFERRED] [semantically similar]
  backend/requirements.txt → pubspec.yaml
- `Linux top-level CMake build (miapp, com.example.miapp)` --semantically_similar_to--> `Windows top-level CMake build (miapp)`  [INFERRED] [semantically similar]
  linux/CMakeLists.txt → windows/CMakeLists.txt
- `iOS Launch Screen Assets` --conceptually_related_to--> `miapp Flutter package (pubspec)`  [INFERRED]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → pubspec.yaml
- `Web entry page (flutter_bootstrap.js)` --references--> `miapp Flutter package (pubspec)`  [INFERRED]
  web/index.html → pubspec.yaml
- `CI test job (format, analyze, test)` --references--> `Analyzer config (flutter_lints)`  [INFERRED]
  .github/workflows/ci.yml → analysis_options.yaml

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Sena domain model (entity, value object, sealed state)** — readme_sena, readme_posicionmano, readme_estadoaprendizaje, readme_campoinvalido [EXTRACTED 1.00]
- **CI quality gate (format, lint, test)** — github_workflows_ci_test_job, analysis_options_flutter_lints_config, pubspec_miapp [INFERRED 0.85]
- **Supabase-backed auth stack (Flutter client + Python backend)** — pubspec_supabase_flutter, backend_requirements_supabase, backend_requirements_pyjwt, pubspec_flutter_dotenv [INFERRED 0.75]

## Communities (63 total, 11 thin omitted)

### Community 0 - "Auth Service & Providers"
Cohesion: 0.05
Nodes (32): _authService, authServiceProvider, client, _initSession, login, logout, register, supabaseClientProvider (+24 more)

### Community 1 - "iOS/macOS App Delegates"
Cohesion: 0.06
Nodes (16): app_links, Cocoa, Flutter, FlutterMacOS, Foundation, AppDelegate, SceneDelegate, RunnerTests (+8 more)

### Community 2 - "Game Match Models"
Cohesion: 0.05
Nodes (32): Dificultad, dificultad, fecha, id, Partida, preguntas, puntuacion, rachaActual (+24 more)

### Community 3 - "Linux GTK Runner"
Cohesion: 0.08
Nodes (14): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+6 more)

### Community 4 - "Hand Landmark Models"
Cohesion: 0.06
Nodes (26): fromJson, hashCode, Landmark, operator, toJson, toString, x, y (+18 more)

### Community 5 - "Camera Detection Service"
Cohesion: 0.07
Nodes (23): _activeCamera, _cameraController, _cameras, canSwitchCamera, controller, dispose, _handLandmarker, handsStream (+15 more)

### Community 6 - "Custom Painters & Questions"
Cohesion: 0.07
Nodes (21): _BottomWavePainter, build, child, fillColor, lineColor, paint, shouldRepaint, _TopWavePainter (+13 more)

### Community 7 - "Backend Config & Seed"
Cohesion: 0.10
Nodes (6): health_check(), Settings, poblar_catalogo(), get_supabase_admin(), ejecutar_seed(), root()

### Community 8 - "Windows Runner Entry"
Cohesion: 0.12
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 9 - "Project Dependencies & CI"
Cohesion: 0.11
Nodes (22): Analyzer config (flutter_lints), FastAPI, PyJWT (JWT verification), Python backend dependencies (FastAPI, Supabase, PyJWT), supabase (Python client), claude.md (empty project notes), CI Workflow (GitHub Actions), CI test job (format, analyze, test) (+14 more)

### Community 10 - "Backend Progress API"
Cohesion: 0.16
Nodes (6): actualizar_progreso_sena(), obtener_progreso_sena(), obtener_progreso_usuario(), EstadoAprendizajeResponse, EstadoAprendizajeUpdate, EstadoTipo

### Community 11 - "Senas Providers"
Cohesion: 0.11
Nodes (14): true, client, null, obtenerTodas, repository, senaPorIdProvider, senas, senasFutureProvider (+6 more)

### Community 12 - "Learning State Model"
Cohesion: 0.12
Nodes (18): diasSinPracticar, Dominada, EnPractica, EstadoAprendizaje, etiqueta, fechaDominada, fromJson, hashCode (+10 more)

### Community 13 - "Backend Matches API"
Cohesion: 0.19
Nodes (7): listar_partidas_usuario(), registrar_partida(), DificultadNivel, PartidaCreate, PartidaResponse, PreguntaCreate, PreguntaResponse

### Community 14 - "Home & Category Views"
Cohesion: 0.12
Nodes (12): homeNavigationProvider, build, HomePage, categoria, CategoriaDetalleView, build, _colorForCategoria, _colorForEstado (+4 more)

### Community 15 - "Sena Entity Model"
Cohesion: 0.11
Nodes (17): categoria, copyWith, debeRecomendarRepaso, descripcion, estadoAprendizaje, fromJson, hashCode, id (+9 more)

### Community 16 - "Win32 Window Lifecycle"
Cohesion: 0.19
Nodes (5): Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, instance_

### Community 17 - "Backend Senas API"
Cohesion: 0.25
Nodes (9): listar_senas(), obtener_categorias(), obtener_sena(), CategoriaResumen, PosicionReferenciaBase, PosicionReferenciaResponse, SenaBase, SenaCreate (+1 more)

### Community 18 - "Practice State"
Cohesion: 0.12
Nodes (13): canSwitchCamera, controller, copyWith, detectedHands, errorMessage, hasError, hasHandsDetected, isFrontCamera (+5 more)

### Community 19 - "Register Page"
Cohesion: 0.12
Nodes (15): bgColor, buttonTeal, _confirmPasswordController, coralColor, createState, darkTeal, dispose, _emailController (+7 more)

### Community 20 - "Senas Repository Layer"
Cohesion: 0.14
Nodes (12): SenasLocales, obtenerPendientes, obtenerPorId, obtenerTodas, SenasRepository, _cache, _client, _fallback (+4 more)

### Community 21 - "Backend Users API"
Cohesion: 0.21
Nodes (5): actualizar_perfil(), obtener_perfil_actual(), UsuarioBase, UsuarioResponse, UsuarioUpdate

### Community 22 - "Practice Provider"
Cohesion: 0.13
Nodes (10): cameraDetectionServiceProvider, _cameraService, dispose, handleAppLifecycleState, _handsSubscription, _initHandsListener, initialize, service (+2 more)

### Community 23 - "Home Bottom Navigation"
Cohesion: 0.13
Nodes (8): _buildNavItem, _darkTeal, _grey, icon, label, _lightTealBg, _NavTab, _tabs

### Community 24 - "JSON Parsing Utils"
Cohesion: 0.13
Nodes (13): campo, fecha, leerDecimal, leerEntero, leerEnteros, leerFecha, leerMapa, leerTexto (+5 more)

### Community 25 - "Local Senas Service"
Cohesion: 0.14
Nodes (9): _cache, _lector, LectorDeAssets, obtenerPendientes, obtenerPorId, obtenerTodas, ruta, _json (+1 more)

### Community 26 - "Dictionary View"
Cohesion: 0.13
Nodes (12): _agruparPorCategoria, categoria, categoriaSenas, color, _colorForCategoria, createState, emoji, _iconForCategoria (+4 more)

### Community 27 - "Backend Auth Dependencies"
Cohesion: 0.20
Nodes (4): get_current_user(), get_db(), get_optional_current_user(), get_user_supabase_client()

### Community 28 - "Profile & Progress Ring"
Cohesion: 0.15
Nodes (7): color, icon, label, value, build, progress, size

### Community 29 - "Hand Position Validator"
Cohesion: 0.15
Nodes (7): _anguloEntre, _distanciaEntre, _modulo, ValidadorPosicion, validar, _vector, main

### Community 30 - "Login Page"
Cohesion: 0.14
Nodes (12): bgColor, _buildSocialButton, buttonTeal, coralColor, createState, darkTeal, dispose, _emailController (+4 more)

### Community 31 - "Windows Plugin Registry"
Cohesion: 0.18
Nodes (5): RegisterPlugins(), Win32Window, child_content_, quit_on_close_, window_handle_

### Community 32 - "Auth & Practice Notifiers"
Cohesion: 0.22
Nodes (11): AuthNotifier, AuthAuthenticated, AuthError, AuthInitial, AuthLoading, AuthState, AuthUnauthenticated, email (+3 more)

### Community 33 - "Windows Flutter Window"
Cohesion: 0.17
Nodes (3): FlutterWindow, flutter_controller_, project_

### Community 34 - "App Theme"
Cohesion: 0.17
Nodes (10): AppTheme, bgCream, buttonTeal, cardBg, coral, darkTeal, grey, light (+2 more)

### Community 35 - "Sena Chip Widget"
Cohesion: 0.17
Nodes (10): Sena, build, _colorForCategoria, _colorForEstado, _iconForSena, _labelForEstado, onTap, _resumenDescripcion (+2 more)

### Community 37 - "Web Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 38 - "Shared UI Widgets"
Cohesion: 0.20
Nodes (7): OceanBackground, _StatCard, CategoryDropletIcon, build, ListaSenasView, ProgressRing, SenaChip

### Community 39 - "Matches Repository"
Cohesion: 0.22
Nodes (6): guardarPartida, obtenerHistorial, PartidasLocales, guardarPartida, obtenerHistorial, PartidasRepository

### Community 40 - "Game View"
Cohesion: 0.24
Nodes (6): build, createState, JuegoView, _JuegoViewState, CategoriaTile, _CategoriaTileState

### Community 41 - "Practice View"
Cohesion: 0.24
Nodes (6): practicaProvider, build, createState, didChangeAppLifecycleState, dispose, initState

### Community 43 - "Stateful Auth Pages"
Cohesion: 0.28
Nodes (6): LoginPage, _LoginPageState, RegisterPage, _RegisterPageState, PracticaView, _PracticaViewState

### Community 44 - "Widget & Domain Tests"
Cohesion: 0.22
Nodes (3): ejemplo, main, main

### Community 45 - "Route Names"
Cohesion: 0.22
Nodes (7): home, homePath, login, loginPath, register, registerPath, RouteNames

### Community 46 - "Auth-Gated Views"
Cohesion: 0.28
Nodes (6): authNotifierProvider, build, build, usuarioFutureProvider, build, PerfilView

### Community 47 - "Exception Types"
Cohesion: 0.29
Nodes (6): CampoInvalido, CameraDetectionException, CameraInitializationException, CameraPermissionException, NoCameraAvailableException, UnsupportedPlatformException

### Community 49 - "App Entry Point"
Cohesion: 0.29
Nodes (3): build, main, MyApp

### Community 50 - "Desktop CMake Builds"
Cohesion: 0.47
Nodes (6): Linux top-level CMake build (miapp, com.example.miapp), Linux flutter_assemble / flutter library target, Linux runner executable (GTK), Windows top-level CMake build (miapp), Windows flutter_assemble / flutter_wrapper_app targets, Windows runner executable (WIN32)

### Community 51 - "Supabase Config"
Cohesion: 0.40
Nodes (3): anonKey, SupabaseConfig, url

### Community 52 - "Sena Detail View"
Cohesion: 0.40
Nodes (3): build, DetalleSenaView, senaId

### Community 53 - "Win32 Point"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 54 - "Win32 Size"
Cohesion: 0.50
Nodes (3): Size, height, width

## Ambiguous Edges - Review These
- `Miapp - Diccionario de Lengua de Senas` → `claude.md (empty project notes)`  [AMBIGUOUS]
  claude.md · relation: conceptually_related_to

## Knowledge Gaps
- **356 isolated node(s):** `SupabaseConfig`, `url`, `anonKey`, `appRouter`, `RouteNames` (+351 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 517 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **11 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `CampoInvalido` connect `Exception Types` to `JSON Parsing Utils`, `Local Senas Service`, `Widget & Domain Tests`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **Are the 5 inferred relationships involving `miapp Flutter package (pubspec)` (e.g. with `Analyzer config (flutter_lints)` and `CI test job (format, analyze, test)`) actually correct?**
  _`miapp Flutter package (pubspec)` has 5 INFERRED edges - model-reasoned connections that need verification._
- **What connects `SupabaseConfig`, `url`, `anonKey` to the rest of the system?**
  _356 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Auth Service & Providers` be split into smaller, more focused modules?**
  _Cohesion score 0.04591836734693878 - nodes in this community are weakly interconnected._
- **Why does `Usuario` connect `Game Match Models` to `Auth Service & Providers`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Should `iOS/macOS App Delegates` be split into smaller, more focused modules?**
  _Cohesion score 0.05807200929152149 - nodes in this community are weakly interconnected._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `Miapp - Diccionario de Lengua de Senas` and `claude.md (empty project notes)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._