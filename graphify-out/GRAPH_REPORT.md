# Graph Report - miapp  (2026-11-22)

## Corpus Check
- 141 files · ~845,360 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 59 file(s) not represented in the graph (top: .xml 10, (none) 9, .xcconfig 8)

## Summary
- 1481 nodes · 2194 edges · 103 communities (85 shown, 18 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 52 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `6c023f8d`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- auth_providers.dart
- iOS/macOS App Delegates
- clasificador_knn_service.dart
- Linux GTK Runner
- sena_model.dart
- camera_detection_service.dart
- ocean_background.dart
- Backend Config & Seed
- package:flutter/material.dart
- Project Dependencies & CI
- Backend Progress API
- practica_provider.dart
- Learning State Model
- Backend Matches API
- categoria_detalle_view.dart
- validador_posicion_service.dart
- Win32 Window Lifecycle
- Backend Senas API
- practica_state.dart
- login_page.dart
- siguiente_progreso
- usuarios.py
- cultura_view.dart
- dialogo_app.dart
- encabezado_pantalla.dart
- senas_provider.dart
- register_page.dart
- sesion_segura_test.dart
- perfil_view.dart
- reconocimiento_senas_test.dart
- api_senas_repository.dart
- Windows Plugin Registry
- auth_google_test.dart
- Windows Flutter Window
- App Theme
- home_page.dart
- windows/flutter/generated_plugin_registrant.cc
- Web Manifest
- package:flutter_riverpod/flutter_riverpod.dart
- json_utils.dart
- juego_view.dart
- practica_view.dart
- Win32 Message Handling
- sena_detalle_view.dart
- test_seguridad.py
- api_client.dart
- authNotifierProvider
- package:flutter_test/flutter_test.dart
- generar_muestras.py
- resumen_partida_model.dart
- Desktop CMake Builds
- Supabase Config
- racha_calendario.dart
- Point
- clasificador_knn_test.dart
- Android Main Activity
- Backend Run Script
- clasificador_numeros_service.dart
- estabilizador_reconocimiento_service.dart
- app_router.dart
- sena_chip.dart
- static const
- clasificador_letras_service.dart
- CameraDetectionException
- reconocimiento_sena_model.dart
- usuarioFutureProvider
- auth_service.dart
- posicion_mano_model.dart
- resultado_validacion_model.dart
- landmark_model.dart
- perfil_provider.dart
- senas_locales_service.dart
- get_current_user
- bienvenida_animada.dart
- api_usuario_repository.dart
- audio_numeros_service.dart
- package:miapp/features/perfil/models/usuario_model.dart
- usuario_repository.dart
- package:miapp/features/senas/models/sena_model.dart
- _BienvenidaAnimadaState
- widget_test.dart
- icono_categoria.dart
- sena_test.dart
- build
- Size
- _HomePageState
- package:google_fonts/google_fonts.dart
- comparaciones_utils.dart
- MaterialPageRoute
- racha_celebracion.dart
- proyecto.md
- string
- DateTime
- CLAUDE.md

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 21 edges
2. `get_supabase_admin()` - 15 edges
3. `authNotifierProvider` - 12 edges
4. `calcular_racha()` - 11 edges
5. `miapp Flutter package (pubspec)` - 11 edges
6. `get_current_user()` - 10 edges
7. `registrar_practica_sena()` - 10 edges
8. `siguiente_progreso()` - 10 edges
9. `PartidaCreate` - 10 edges
10. `AuthState` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Linux top-level CMake build (miapp, com.example.miapp)` --semantically_similar_to--> `Windows top-level CMake build (miapp)`  [INFERRED] [semantically similar]
  linux/CMakeLists.txt → windows/CMakeLists.txt
- `supabase (Python client)` --semantically_similar_to--> `supabase_flutter`  [INFERRED] [semantically similar]
  backend/requirements.txt → pubspec.yaml
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
- **Supabase-backed auth stack (Flutter client + Python backend)** — pubspec_supabase_flutter, backend_requirements_supabase, backend_requirements_pyjwt, pubspec_flutter_dotenv [INFERRED 0.75]
- **CI quality gate (format, lint, test)** — github_workflows_ci_test_job, analysis_options_flutter_lints_config, pubspec_miapp [INFERRED 0.85]

## Communities (103 total, 18 thin omitted)

### Community 0 - "auth_providers.dart"
Cohesion: 0.12
Nodes (13): AuthNotifier, _authService, client, dispose, _initSession, login, loginConGoogle, logout (+5 more)

### Community 1 - "iOS/macOS App Delegates"
Cohesion: 0.05
Nodes (18): app_links, audioplayers_darwin, Cocoa, Flutter, flutter_secure_storage_darwin, FlutterMacOS, Foundation, AppDelegate (+10 more)

### Community 2 - "clasificador_knn_service.dart"
Cohesion: 0.08
Nodes (23): _angulo, _apoyosPulgar, asset, _cadenas, ClasificadorKnn, confianzaCerca, desdeJson, _dist (+15 more)

### Community 3 - "Linux GTK Runner"
Cohesion: 0.07
Nodes (14): fl_register_plugins(), main(), first_frame_cb(), my_application_activate(), my_application_class_init(), my_application_dispose(), my_application_init(), my_application_local_command_line() (+6 more)

### Community 4 - "sena_model.dart"
Cohesion: 0.11
Nodes (17): categoria, copyWith, debeRecomendarRepaso, descripcion, estadoAprendizaje, fromJson, hashCode, id (+9 more)

### Community 5 - "camera_detection_service.dart"
Cohesion: 0.06
Nodes (26): _activeCamera, _cameraController, CameraDetectionService, _cameras, canSwitchCamera, controller, dispose, _handLandmarker (+18 more)

### Community 6 - "ocean_background.dart"
Cohesion: 0.10
Nodes (16): _BottomWavePainter, build, child, fillColor, lineColor, OceanBackground, paint, shouldRepaint (+8 more)

### Community 7 - "Backend Config & Seed"
Cohesion: 0.14
Nodes (3): health_check(), Settings, root()

### Community 8 - "package:flutter/material.dart"
Cohesion: 0.10
Nodes (13): build, children, CuadriculaDos, espacio, _agruparPorCategoria, categoria, categoriaSenas, CategoriaTile (+5 more)

### Community 9 - "Project Dependencies & CI"
Cohesion: 0.11
Nodes (22): Analyzer config (flutter_lints), FastAPI, PyJWT (JWT verification), Python backend dependencies (FastAPI, Supabase, PyJWT), supabase (Python client), claude.md (empty project notes), CI Workflow (GitHub Actions), CI test job (format, analyze, test) (+14 more)

### Community 10 - "Backend Progress API"
Cohesion: 0.15
Nodes (8): actualizar_progreso_sena(), obtener_progreso_sena(), obtener_progreso_usuario(), registrar_practica_sena(), EstadoAprendizajeResponse, EstadoAprendizajeUpdate, EstadoTipo, PracticaSenaRegistro

### Community 11 - "practica_provider.dart"
Cohesion: 0.05
Nodes (32): alfa, area, _audio, audioNumerosServiceProvider, cameraDetectionServiceProvider, _cameraService, _capturar, _clasificador (+24 more)

### Community 12 - "Learning State Model"
Cohesion: 0.10
Nodes (21): contoHoy, diasParaDominar, diasRestantes, diasSinPracticar, Dominada, EnPractica, EstadoAprendizaje, etiqueta (+13 more)

### Community 13 - "Backend Matches API"
Cohesion: 0.14
Nodes (10): listar_partidas_usuario(), registrar_partida(), registrar_resultado_juego(), DificultadNivel, PartidaCreate, PartidaResponse, PreguntaCreate, PreguntaResponse (+2 more)

### Community 14 - "categoria_detalle_view.dart"
Cohesion: 0.12
Nodes (12): acepta, _Buscador, categoria, _coincide, controller, createState, dispose, etiqueta (+4 more)

### Community 15 - "validador_posicion_service.dart"
Cohesion: 0.14
Nodes (8): _anguloEntre, _distanciaEntre, _modulo, ValidadorPosicion, validar, _vector, cuadrado, main

### Community 16 - "Win32 Window Lifecycle"
Cohesion: 0.18
Nodes (5): Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, instance_

### Community 17 - "Backend Senas API"
Cohesion: 0.12
Nodes (13): get_db(), listar_senas(), obtener_categorias(), obtener_sena(), poblar_catalogo(), get_supabase_admin(), get_user_supabase_client(), CategoriaResumen (+5 more)

### Community 18 - "practica_state.dart"
Cohesion: 0.10
Nodes (17): canSwitchCamera, controller, copyWith, detectedHands, errorMessage, extensiones, hasError, hasHandsDetected (+9 more)

### Community 19 - "login_page.dart"
Cohesion: 0.13
Nodes (11): bgColor, buttonTeal, coralColor, createState, darkTeal, dispose, _emailController, lightTealBg (+3 more)

### Community 20 - "siguiente_progreso"
Cohesion: 0.13
Nodes (6): siguiente_progreso(), xp_juego(), xp_practica(), SiguienteProgresoTest, XpJuegoTest, XpPracticaTest

### Community 21 - "usuarios.py"
Cohesion: 0.15
Nodes (8): validar_fecha_local(), actualizar_perfil(), listar_dias_practica(), obtener_perfil_actual(), registrar_practica(), PracticaRegistro, UsuarioBase, UsuarioResponse

### Community 22 - "cultura_view.dart"
Cohesion: 0.12
Nodes (13): DatoLsc, datos, icono, TemaLsc, temasLsc, texto, titulo, build (+5 more)

### Community 23 - "dialogo_app.dart"
Cohesion: 0.12
Nodes (15): acciones, BotonDialogo, build, color, colorIcono, contenido, decoracionCampo, descripcion (+7 more)

### Community 24 - "encabezado_pantalla.dart"
Cohesion: 0.12
Nodes (15): build, _Circulo, color, _crema, EncabezadoPantalla, etiqueta, icono, onTap (+7 more)

### Community 25 - "senas_provider.dart"
Cohesion: 0.18
Nodes (8): i, null, obtenerTodas, _ordenCategorias, _rangoCategoria, repository, senaPorIdProvider, senas

### Community 26 - "register_page.dart"
Cohesion: 0.12
Nodes (15): bgColor, buttonTeal, _confirmPasswordController, coralColor, createState, darkTeal, dispose, _emailController (+7 more)

### Community 27 - "sesion_segura_test.dart"
Cohesion: 0.09
Nodes (18): accessToken, _almacen, _anterior, clave, hasAccessToken, initialize, persistSession, removePersistedSession (+10 more)

### Community 28 - "perfil_view.dart"
Cohesion: 0.05
Nodes (44): _BotonPrincipal, _ModoTile, _RespuestaCard, _ResumenPartida, _SelectorDificultad, _AcercaDe, _Aviso, _Cabecera (+36 more)

### Community 29 - "reconocimiento_senas_test.dart"
Cohesion: 0.10
Nodes (17): c, clasificador, conZ, cx, cy, dorso, escala, giro (+9 more)

### Community 30 - "api_senas_repository.dart"
Cohesion: 0.14
Nodes (11): JuegoProvider, _api, ApiSenasRepository, _cache, _fallback, obtenerPendientes, obtenerPorId, obtenerTodas (+3 more)

### Community 31 - "Windows Plugin Registry"
Cohesion: 0.24
Nodes (4): Win32Window, child_content_, quit_on_close_, window_handle_

### Community 32 - "auth_google_test.dart"
Cohesion: 0.16
Nodes (16): AuthAuthenticated, AuthError, AuthInitial, AuthLoading, AuthState, AuthUnauthenticated, email, message (+8 more)

### Community 33 - "Windows Flutter Window"
Cohesion: 0.12
Nodes (4): FlutterWindow, flutter_controller_, FlutterWindow::FlutterWindow(), project_

### Community 34 - "App Theme"
Cohesion: 0.15
Nodes (11): AppTheme, bgCream, buttonTeal, cardBg, coral, darkTeal, grey, light (+3 more)

### Community 35 - "home_page.dart"
Cohesion: 0.11
Nodes (13): _bienvenida, _buildNavItem, _carga, createState, _darkTeal, dispose, _grey, icon (+5 more)

### Community 37 - "Web Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 38 - "package:flutter_riverpod/flutter_riverpod.dart"
Cohesion: 0.20
Nodes (3): ApiClient, apiClientProvider, etiqueta

### Community 39 - "json_utils.dart"
Cohesion: 0.14
Nodes (13): campo, fecha, leerDecimal, leerEntero, leerEnteros, leerFecha, leerMapa, leerTexto (+5 more)

### Community 40 - "juego_view.dart"
Cohesion: 0.04
Nodes (45): _aciertos, actual, _asset, _Categoria, createState, _datos, _decoracionCard, detalle (+37 more)

### Community 41 - "practica_view.dart"
Cohesion: 0.10
Nodes (19): SubidaRacha, practicaProvider, _aciertoRegistrado, build, _colorEsqueleto, conf, createState, didChangeAppLifecycleState (+11 more)

### Community 43 - "sena_detalle_view.dart"
Cohesion: 0.12
Nodes (15): senasRepositoryProvider, _BotonFlecha, child, estado, extra, icono, ids, _iniciarPractica (+7 more)

### Community 44 - "test_seguridad.py"
Cohesion: 0.23
Nodes (3): UsuarioUpdate, H02SeedSinAutenticacion, H03PerfilNoAceptaEstadisticas

### Community 45 - "api_client.dart"
Cohesion: 0.12
Nodes (13): _auth, _baseUrl, defaultBaseUrl, _enviar, haySesion, _http, mensaje, patch (+5 more)

### Community 46 - "authNotifierProvider"
Cohesion: 0.22
Nodes (14): authNotifierProvider, authServiceProvider, AccesoGoogle, build, usuarioRepositoryProvider, build, _cambiarContrasena, _editarNombre (+6 more)

### Community 47 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.15
Nodes (6): main, hoy, main, ejemplo, main, main

### Community 48 - "generar_muestras.py"
Cohesion: 0.26
Nodes (4): angulo(), leer(), main(), rasgos()

### Community 49 - "resumen_partida_model.dart"
Cohesion: 0.14
Nodes (11): Dificultad, dificultad, fromJson, hashCode, operator, puntuacion, rachaMaxima, ResumenPartida (+3 more)

### Community 50 - "Desktop CMake Builds"
Cohesion: 0.47
Nodes (6): Linux top-level CMake build (miapp, com.example.miapp), Linux flutter_assemble / flutter library target, Linux runner executable (GTK), Windows top-level CMake build (miapp), Windows flutter_assemble / flutter_wrapper_app targets, Windows runner executable (WIN32)

### Community 51 - "Supabase Config"
Cohesion: 0.29
Nodes (4): anonKey, claveSesion, SupabaseConfig, url

### Community 52 - "racha_calendario.dart"
Cohesion: 0.12
Nodes (17): diasPracticaProvider, build, createState, _Dia, diasDeRacha, enRacha, esHoy, hoy (+9 more)

### Community 53 - "Point"
Cohesion: 0.50
Nodes (3): Point, x, y

### Community 54 - "clasificador_knn_test.dart"
Cohesion: 0.18
Nodes (8): aspectoB, b, datos, json, knn, main, muestras, puntos

### Community 63 - "clasificador_numeros_service.dart"
Cohesion: 0.14
Nodes (13): _angulo, _apoyosPulgar, ClasificadorNumeros, clasificar, _contactos, _dedos, desdeExtensiones, dist (+5 more)

### Community 64 - "estabilizador_reconocimiento_service.dart"
Cohesion: 0.15
Nodes (9): actualizar, EstabilizadorReconocimiento, _frames, framesConfirmacion, _hayMano, _parcial, reiniciar, umbralConfianza (+1 more)

### Community 65 - "app_router.dart"
Cohesion: 0.13
Nodes (4): appRouter, build, main, MyApp

### Community 66 - "sena_chip.dart"
Cohesion: 0.15
Nodes (9): Sena, build, colorEstado, etiquetaCorta, onTap, sena, SenaChip, _SinImagen (+1 more)

### Community 67 - "static const"
Cohesion: 0.22
Nodes (7): home, homePath, login, loginPath, register, registerPath, RouteNames

### Community 68 - "clasificador_letras_service.dart"
Cohesion: 0.15
Nodes (9): ClasificadorLetras, _doblados, _entre, letrasSoportadas, _numeros, puntuar, _r, _Rasgos (+1 more)

### Community 69 - "CameraDetectionException"
Cohesion: 0.40
Nodes (5): CameraDetectionException, CameraInitializationException, CameraPermissionException, NoCameraAvailableException, UnsupportedPlatformException

### Community 70 - "reconocimiento_sena_model.dart"
Cohesion: 0.18
Nodes (8): ClasificacionSena, confianza, confirmada, detenido, estado, EstadoReconocimiento, ResultadoReconocimiento, sena

### Community 71 - "usuarioFutureProvider"
Cohesion: 0.17
Nodes (13): LoginPage, _LoginPageState, RegisterPage, _RegisterPageState, JuegoView, _JuegoViewState, _registrarResultado, usuarioFutureProvider (+5 more)

### Community 72 - "auth_service.dart"
Cohesion: 0.15
Nodes (9): cambiarContrasena, cambiosDeSesion, cerrarSesion, _client, iniciarConGoogle, iniciarSesion, redirectMovil, registrarse (+1 more)

### Community 73 - "posicion_mano_model.dart"
Cohesion: 0.18
Nodes (9): anguloPulgar, distanciaIndiceMedio, fromJson, hashCode, landmarksClave, operator, PosicionMano, toJson (+1 more)

### Community 74 - "resultado_validacion_model.dart"
Cohesion: 0.20
Nodes (8): correcto, fromJson, hashCode, operator, ResultadoValidacion, sugerencia, toJson, toString

### Community 75 - "landmark_model.dart"
Cohesion: 0.20
Nodes (9): fromJson, hashCode, Landmark, operator, toJson, toString, x, y (+1 more)

### Community 76 - "perfil_provider.dart"
Cohesion: 0.25
Nodes (4): Usuario, obtenerUsuario, repo, watch

### Community 77 - "senas_locales_service.dart"
Cohesion: 0.22
Nodes (8): _cache, _lector, LectorDeAssets, obtenerPendientes, obtenerPorId, obtenerTodas, registrarPractica, ruta

### Community 78 - "get_current_user"
Cohesion: 0.32
Nodes (3): get_current_user(), get_optional_current_user(), H08ErrorDeAuthNoFiltraDetalles

### Community 79 - "bienvenida_animada.dart"
Cohesion: 0.12
Nodes (14): alTerminar, _arrancar, avance, build, cargando, createState, dispose, _entrada (+6 more)

### Community 80 - "api_usuario_repository.dart"
Cohesion: 0.22
Nodes (8): actualizarNombre, _api, _desdeJson, obtenerDiasPractica, obtenerUsuario, registrarPractica, registrarResultadoJuego, _vacio

### Community 81 - "audio_numeros_service.dart"
Cohesion: 0.29
Nodes (4): AudioNumerosService, dispose, _player, reproducir

### Community 82 - "package:miapp/features/perfil/models/usuario_model.dart"
Cohesion: 0.22
Nodes (5): main, _usuario, conRacha, hoy, main

### Community 83 - "usuario_repository.dart"
Cohesion: 0.25
Nodes (7): ApiUsuarioRepository, actualizarNombre, obtenerDiasPractica, obtenerUsuario, registrarPractica, registrarResultadoJuego, UsuarioRepository

### Community 84 - "package:miapp/features/senas/models/sena_model.dart"
Cohesion: 0.33
Nodes (4): obtenerPendientes, obtenerPorId, obtenerTodas, registrarPractica

### Community 85 - "_BienvenidaAnimadaState"
Cohesion: 0.23
Nodes (8): BienvenidaAnimada, _BienvenidaAnimadaState, _DialogoTexto, _DialogoTextoState, RachaCelebracion, _RachaCelebracionState, RachaPerdida, _RachaPerdidaState

### Community 86 - "widget_test.dart"
Cohesion: 0.20
Nodes (7): AuthService, _AuthServiceFalso, _AuthServiceFalso, cambiosDeSesion, main, noSuchMethod, usuarioActual

### Community 87 - "icono_categoria.dart"
Cohesion: 0.33
Nodes (5): iconoCategoria, imagenDeSena, normalizarBusqueda, tildes, toLowerCase

### Community 88 - "sena_test.dart"
Cohesion: 0.22
Nodes (4): ApiException, CampoInvalido, _json, main

### Community 89 - "build"
Cohesion: 0.33
Nodes (3): build, build, _cerrarSesion

### Community 90 - "Size"
Cohesion: 0.50
Nodes (3): Size, height, width

### Community 91 - "_HomePageState"
Cohesion: 0.40
Nodes (6): homeNavigationProvider, build, HomePage, _HomePageState, build, usuarioProvider

### Community 215 - "racha_celebracion.dart"
Cohesion: 0.07
Nodes (26): _anim, anterior, _apagado, avisarSiPerdioRacha, build, _caida, _cambioNumero, clave (+18 more)

### Community 252 - "proyecto.md"
Cohesion: 0.08
Nodes (24): 10. Pruebas y criterios de aceptación, 11. Estrategia de implementación, 12. Instrucciones para el agente de programación, 13. Evolución futura, 1. Objetivo del producto, 2. Usuarios y necesidad, 3. Alcance del MVP, 4.1 Inicio (+16 more)

### Community 257 - "string"
Cohesion: 0.06
Nodes (18): copyWith, fechaUltimaActividad, hashCode, nombre, operator, partidasJugadas, rachaDias, rachaGlobalMaxima (+10 more)

## Ambiguous Edges - Review These
- `claude.md (empty project notes)` → `Miapp - Diccionario de Lengua de Senas`  [AMBIGUOUS]
  claude.md · relation: conceptually_related_to

## Knowledge Gaps
- **698 isolated node(s):** `SupabaseConfig`, `url`, `anonKey`, `claveSesion`, `statusCode` (+693 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 912 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Win32Window` connect `Windows Plugin Registry` to `Windows Flutter Window`, `string`, `Win32 Message Handling`, `Win32 Window Lifecycle`, `Point`, `Size`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **What connects `SupabaseConfig`, `url`, `anonKey` to the rest of the system?**
  _698 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `auth_providers.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.125 - nodes in this community are weakly interconnected._
- **Why does `get_supabase_admin()` connect `Backend Senas API` to `usuarios.py`, `get_current_user`, `Backend Config & Seed`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Should `iOS/macOS App Delegates` be split into smaller, more focused modules?**
  _Cohesion score 0.05496828752642706 - nodes in this community are weakly interconnected._
- **Why does `PartidaCreate` connect `Backend Matches API` to `test_seguridad.py`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `claude.md (empty project notes)` and `Miapp - Diccionario de Lengua de Senas`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._