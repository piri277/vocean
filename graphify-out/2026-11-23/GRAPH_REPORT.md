# Graph Report - miapp  (2026-11-22)

## Corpus Check
- 155 files · ~857,781 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 59 file(s) not represented in the graph (top: .xml 10, (none) 9, .xcconfig 8)

## Summary
- 1778 nodes · 2707 edges · 107 communities (89 shown, 18 thin omitted)
- Extraction: 98% EXTRACTED · 2% INFERRED · 0% AMBIGUOUS · INFERRED: 57 edges (avg confidence: 0.89)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `5aa635a1`
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
- utils.cpp
- diccionario_view.dart
- Project Dependencies & CI
- routes/progreso.py
- practica_provider.dart
- Learning State Model
- test_reto_diario.py
- categoria_detalle_view.dart
- dart:math
- Win32 Window Lifecycle
- test_seguridad.py
- practica_state.dart
- login_page.dart
- retroalimentacion.dart
- validar_fecha_local
- contenido_lsc.dart
- dialogo_app.dart
- encabezado_pantalla.dart
- senas_provider.dart
- register_page.dart
- sesion_segura_test.dart
- perfil_view.dart
- reconocimiento_senas_test.dart
- StatelessWidget
- Windows Plugin Registry
- auth_google_test.dart
- Windows Flutter Window
- App Theme
- home_page.dart
- windows/flutter/generated_plugin_registrant.cc
- Web Manifest
- widget_test.dart
- api_client.dart
- juego_view.dart
- practica_view.dart
- Win32 Message Handling
- sena_detalle_view.dart
- test_xp.py
- sena.py
- resumen_partida_model.dart
- clasificador_knn_test.dart
- generar_muestras.py
- banco_juego.dart
- Desktop CMake Builds
- Supabase Config
- racha_calendario.dart
- Point
- quiz_cultura.dart
- Android Main Activity
- Backend Run Script
- clasificador_numeros_service.dart
- estabilizador_reconocimiento_service.dart
- test_reto_diario.py
- sena_chip.dart
- api_usuario_repository.dart
- clasificador_letras_service.dart
- cultura_view.dart
- reconocimiento_sena_model.dart
- ConsumerState
- auth_service.dart
- posicion_mano_model.dart
- resultado_validacion_model.dart
- landmark_model.dart
- usuarioFutureProvider
- historias_tema.dart
- usuario_repository.dart
- dependencies.py
- repo_usuario_falso.dart
- audio_numeros_service.dart
- package:flutter_test/flutter_test.dart
- juego_view_test.dart
- json_utils.dart
- State
- flash_cards_test.dart
- package:flutter/services.dart
- usuarioProvider
- CustomPainter
- bienvenida_animada_test.dart
- authNotifierProvider
- package:flutter/material.dart
- main.dart
- app_router.dart
- perfil_provider.dart
- hand_landmarks_painter.dart
- package:miapp/features/perfil/models/usuario_model.dart
- List
- racha_celebracion.dart
- proyecto.md
- DateTime
- CLAUDE.md

## God Nodes (most connected - your core abstractions)
1. `Win32Window` - 21 edges
2. `get_supabase_admin()` - 16 edges
3. `registrar_reto_diario()` - 13 edges
4. `authNotifierProvider` - 12 edges
5. `get_current_user()` - 11 edges
6. `calcular_racha()` - 11 edges
7. `usuarioFutureProvider` - 11 edges
8. `miapp Flutter package (pubspec)` - 11 edges
9. `get_db()` - 10 edges
10. `registrar_practica_sena()` - 10 edges

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

## Communities (107 total, 18 thin omitted)

### Community 0 - "auth_providers.dart"
Cohesion: 0.14
Nodes (11): AuthNotifier, _authService, client, dispose, _initSession, login, loginConGoogle, logout (+3 more)

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
Nodes (31): _activeCamera, _cameraController, CameraDetectionException, CameraDetectionService, CameraInitializationException, CameraPermissionException, _cameras, canSwitchCamera (+23 more)

### Community 6 - "ocean_background.dart"
Cohesion: 0.22
Nodes (7): build, child, fillColor, lineColor, OceanBackground, paint, shouldRepaint

### Community 7 - "utils.cpp"
Cohesion: 0.19
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 8 - "diccionario_view.dart"
Cohesion: 0.11
Nodes (10): _agruparPorCategoria, categoria, categoriaSenas, CategoriaTile, dominadas, enPractica, _ResumenProgreso, total (+2 more)

### Community 9 - "Project Dependencies & CI"
Cohesion: 0.11
Nodes (22): Analyzer config (flutter_lints), FastAPI, PyJWT (JWT verification), Python backend dependencies (FastAPI, Supabase, PyJWT), supabase (Python client), claude.md (empty project notes), CI Workflow (GitHub Actions), CI test job (format, analyze, test) (+14 more)

### Community 10 - "routes/progreso.py"
Cohesion: 0.12
Nodes (8): actualizar_progreso_sena(), obtener_progreso_sena(), obtener_progreso_usuario(), registrar_practica_sena(), EstadoAprendizajeResponse, EstadoAprendizajeUpdate, EstadoTipo, PracticaSenaRegistro

### Community 11 - "practica_provider.dart"
Cohesion: 0.05
Nodes (32): alfa, area, _audio, audioNumerosServiceProvider, cameraDetectionServiceProvider, _cameraService, _capturar, _clasificador (+24 more)

### Community 12 - "Learning State Model"
Cohesion: 0.10
Nodes (21): contoHoy, diasParaDominar, diasRestantes, diasSinPracticar, Dominada, EnPractica, EstadoAprendizaje, etiqueta (+13 more)

### Community 13 - "test_reto_diario.py"
Cohesion: 0.15
Nodes (4): _Consulta, _Db, RecordSupervivenciaTest, RetoDiarioTest

### Community 14 - "categoria_detalle_view.dart"
Cohesion: 0.12
Nodes (12): acepta, _Buscador, categoria, _coincide, controller, createState, dispose, etiqueta (+4 more)

### Community 15 - "dart:math"
Cohesion: 0.25
Nodes (6): _anguloEntre, _distanciaEntre, _modulo, ValidadorPosicion, validar, _vector

### Community 16 - "Win32 Window Lifecycle"
Cohesion: 0.19
Nodes (5): Scale(), Win32Window::Win32Window(), WindowClassRegistrar, class_registered_, instance_

### Community 17 - "test_seguridad.py"
Cohesion: 0.11
Nodes (11): PartidaCreate, PreguntaCreate, PracticaRegistro, UsuarioBase, UsuarioResponse, UsuarioUpdate, H02SeedSinAutenticacion, H03PerfilNoAceptaEstadisticas (+3 more)

### Community 18 - "practica_state.dart"
Cohesion: 0.09
Nodes (19): PracticaNotifier, canSwitchCamera, controller, copyWith, detectedHands, errorMessage, extensiones, hasError (+11 more)

### Community 19 - "login_page.dart"
Cohesion: 0.09
Nodes (14): ApiClient, apiClientProvider, bgColor, buttonTeal, coralColor, createState, darkTeal, dispose (+6 more)

### Community 20 - "retroalimentacion.dart"
Cohesion: 0.07
Nodes (24): activo, _anim, build, child, color, _colores, createState, didUpdateWidget (+16 more)

### Community 21 - "validar_fecha_local"
Cohesion: 0.13
Nodes (7): validar_fecha_local(), actualizar_perfil(), campos_practica(), guardar_dia_practica(), listar_dias_practica(), obtener_perfil_actual(), registrar_practica()

### Community 22 - "contenido_lsc.dart"
Cohesion: 0.11
Nodes (17): correcta, datos, datosDelDiaExtra, enunciado, explicacion, fuente, _funcionPublica, icono (+9 more)

### Community 23 - "dialogo_app.dart"
Cohesion: 0.12
Nodes (15): acciones, BotonDialogo, build, color, colorIcono, contenido, decoracionCampo, descripcion (+7 more)

### Community 24 - "encabezado_pantalla.dart"
Cohesion: 0.12
Nodes (15): build, _Circulo, color, _crema, EncabezadoPantalla, etiqueta, icono, onTap (+7 more)

### Community 25 - "senas_provider.dart"
Cohesion: 0.05
Nodes (31): true, i, null, obtenerTodas, _ordenCategorias, _rangoCategoria, repository, senaPorIdProvider (+23 more)

### Community 26 - "register_page.dart"
Cohesion: 0.12
Nodes (15): bgColor, buttonTeal, _confirmPasswordController, coralColor, createState, darkTeal, dispose, _emailController (+7 more)

### Community 27 - "sesion_segura_test.dart"
Cohesion: 0.09
Nodes (18): accessToken, _almacen, _anterior, clave, hasAccessToken, initialize, persistSession, removePersistedSession (+10 more)

### Community 28 - "perfil_view.dart"
Cohesion: 0.06
Nodes (28): _campo, children, color, confirmar, createState, descripcion, dispose, _ejecutar (+20 more)

### Community 29 - "reconocimiento_senas_test.dart"
Cohesion: 0.10
Nodes (17): c, clasificador, conZ, cx, cy, dorso, escala, giro (+9 more)

### Community 30 - "StatelessWidget"
Cohesion: 0.09
Nodes (21): _Reverso, _TarjetaQuiz, _BotonPrincipal, _InterruptorRepaso, _ModoTile, _OpcionSenas, _RespuestaCard, _ResumenPartida (+13 more)

### Community 31 - "Windows Plugin Registry"
Cohesion: 0.21
Nodes (4): Win32Window, child_content_, quit_on_close_, window_handle_

### Community 32 - "auth_google_test.dart"
Cohesion: 0.16
Nodes (16): AuthAuthenticated, AuthError, AuthInitial, AuthLoading, AuthState, AuthUnauthenticated, email, message (+8 more)

### Community 33 - "Windows Flutter Window"
Cohesion: 0.14
Nodes (3): FlutterWindow, flutter_controller_, project_

### Community 34 - "App Theme"
Cohesion: 0.15
Nodes (11): AppTheme, bgCream, buttonTeal, cardBg, coral, darkTeal, grey, light (+3 more)

### Community 35 - "home_page.dart"
Cohesion: 0.04
Nodes (40): home, homePath, login, loginPath, register, registerPath, RouteNames, alTerminar (+32 more)

### Community 37 - "Web Manifest"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 38 - "widget_test.dart"
Cohesion: 0.20
Nodes (7): AuthService, _AuthServiceFalso, _AuthServiceFalso, cambiosDeSesion, main, noSuchMethod, usuarioActual

### Community 39 - "api_client.dart"
Cohesion: 0.12
Nodes (13): _auth, _baseUrl, defaultBaseUrl, _enviar, haySesion, _http, mensaje, patch (+5 more)

### Community 40 - "juego_view.dart"
Cohesion: 0.03
Nodes (58): _aciertos, activo, actual, _animacion, _asset, _banco, boton, _categoria (+50 more)

### Community 41 - "practica_view.dart"
Cohesion: 0.05
Nodes (38): JuegoProvider, copyWith, fechaUltimaActividad, hashCode, juegosGanados, nombre, operator, partidasJugadas (+30 more)

### Community 43 - "sena_detalle_view.dart"
Cohesion: 0.12
Nodes (15): senasRepositoryProvider, _BotonFlecha, child, estado, extra, icono, ids, _iniciarPractica (+7 more)

### Community 44 - "test_xp.py"
Cohesion: 0.08
Nodes (10): registrar_quiz_cultura(), ResultadoQuiz, siguiente_progreso(), xp_cultura(), xp_juego(), xp_practica(), SiguienteProgresoTest, XpCulturaTest (+2 more)

### Community 45 - "sena.py"
Cohesion: 0.22
Nodes (9): listar_senas(), obtener_categorias(), obtener_sena(), CategoriaResumen, PosicionReferenciaBase, PosicionReferenciaResponse, SenaBase, SenaCreate (+1 more)

### Community 46 - "resumen_partida_model.dart"
Cohesion: 0.15
Nodes (11): Dificultad, dificultad, fromJson, hashCode, operator, puntuacion, rachaMaxima, ResumenPartida (+3 more)

### Community 47 - "clasificador_knn_test.dart"
Cohesion: 0.12
Nodes (11): banco, main, raw, aspectoB, b, datos, json, knn (+3 more)

### Community 48 - "generar_muestras.py"
Cohesion: 0.26
Nodes (4): angulo(), leer(), main(), rasgos()

### Community 49 - "banco_juego.dart"
Cohesion: 0.10
Nodes (19): BancoJuego, CategoriaJuego, claveReto, datos, _dificultadReto, dificultadSupervivencia, esNumero, inversa (+11 more)

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
Cohesion: 0.21
Nodes (6): Point, x, y, Size, height, width

### Community 54 - "quiz_cultura.dart"
Cohesion: 0.07
Nodes (27): _aciertos, _actual, _AvisoRepaso, _azar, build, cantidad, completado, createState (+19 more)

### Community 63 - "clasificador_numeros_service.dart"
Cohesion: 0.14
Nodes (13): _angulo, _apoyosPulgar, ClasificadorNumeros, clasificar, _contactos, _dedos, desdeExtensiones, dist (+5 more)

### Community 64 - "estabilizador_reconocimiento_service.dart"
Cohesion: 0.15
Nodes (9): actualizar, EstabilizadorReconocimiento, _frames, framesConfirmacion, _hayMano, _parcial, reiniciar, umbralConfianza (+1 more)

### Community 65 - "test_reto_diario.py"
Cohesion: 0.13
Nodes (14): listar_partidas_usuario(), registrar_partida(), registrar_resultado_juego(), registrar_reto_diario(), registrar_supervivencia(), xp_reto(), DificultadNivel, PartidaResponse (+6 more)

### Community 66 - "sena_chip.dart"
Cohesion: 0.14
Nodes (10): Sena, build, colorEstado, etiquetaCorta, onTap, sena, SenaChip, _SinImagen (+2 more)

### Community 67 - "api_usuario_repository.dart"
Cohesion: 0.17
Nodes (11): actualizarNombre, _api, _desdeJson, obtenerDiasPractica, obtenerUsuario, registrarPractica, registrarQuizCultura, registrarResultadoJuego (+3 more)

### Community 68 - "clasificador_letras_service.dart"
Cohesion: 0.17
Nodes (9): ClasificadorLetras, _doblados, _entre, letrasSoportadas, _numeros, puntuar, _r, _Rasgos (+1 more)

### Community 69 - "cultura_view.dart"
Cohesion: 0.14
Nodes (9): DatoLsc, TemaLsc, completado, dato, _DatoDelDia, _MitosCard, tema, _TemaCard (+1 more)

### Community 70 - "reconocimiento_sena_model.dart"
Cohesion: 0.18
Nodes (8): ClasificacionSena, confianza, confirmada, detenido, estado, EstadoReconocimiento, ResultadoReconocimiento, sena

### Community 71 - "ConsumerState"
Cohesion: 0.24
Nodes (9): LoginPage, _LoginPageState, RegisterPage, _RegisterPageState, QuizCultura, _QuizCulturaState, HomePage, CategoriaDetalleView (+1 more)

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

### Community 76 - "usuarioFutureProvider"
Cohesion: 0.18
Nodes (12): _registrar, JuegoView, _JuegoViewState, _recordActual, _registrarClasico, _registrarReto, _subirRecordLocal, usuarioFutureProvider (+4 more)

### Community 77 - "historias_tema.dart"
Cohesion: 0.06
Nodes (33): _abrirQuiz, _actual, _BotonRedondo, build, child, _Circulo, color, completado (+25 more)

### Community 78 - "usuario_repository.dart"
Cohesion: 0.17
Nodes (11): ApiUsuarioRepository, actualizarNombre, obtenerDiasPractica, obtenerUsuario, registrarPractica, registrarQuizCultura, registrarResultadoJuego, registrarRetoDiario (+3 more)

### Community 79 - "dependencies.py"
Cohesion: 0.10
Nodes (10): get_current_user(), get_db(), get_db_escritura(), get_optional_current_user(), health_check(), Settings, poblar_catalogo(), get_supabase_admin() (+2 more)

### Community 80 - "repo_usuario_falso.dart"
Cohesion: 0.15
Nodes (12): actualizarNombre, obtenerDiasPractica, obtenerUsuario, quizzes, registrarPractica, registrarQuizCultura, registrarResultadoJuego, registrarRetoDiario (+4 more)

### Community 81 - "audio_numeros_service.dart"
Cohesion: 0.29
Nodes (4): AudioNumerosService, dispose, _player, reproducir

### Community 82 - "package:flutter_test/flutter_test.dart"
Cohesion: 0.14
Nodes (6): main, ejemplo, main, cuadrado, main, main

### Community 83 - "juego_view_test.dart"
Cohesion: 0.12
Nodes (13): _abrir, ensureVisible, _espera, find, main, _primeraOpcion, pump, pumpWidget (+5 more)

### Community 85 - "json_utils.dart"
Cohesion: 0.12
Nodes (15): ApiException, campo, CampoInvalido, fecha, leerDecimal, leerEntero, leerEnteros, leerFecha (+7 more)

### Community 86 - "State"
Cohesion: 0.15
Nodes (18): AnimacionRespuesta, _AnimacionRespuestaState, CelebracionFinal, _CelebracionFinalState, _FlashCard, _FlashCardState, HistoriasTema, _HistoriasTemaState (+10 more)

### Community 87 - "flash_cards_test.dart"
Cohesion: 0.29
Nodes (5): _abrir, main, pump, pumpWidget, tema

### Community 89 - "usuarioProvider"
Cohesion: 0.13
Nodes (18): authServiceProvider, AccesoGoogle, build, CulturaView, homeNavigationProvider, build, _HomePageState, build (+10 more)

### Community 90 - "CustomPainter"
Cohesion: 0.33
Nodes (5): _Chispas, _Confeti, _BottomWavePainter, _TopWavePainter, HandLandmarksPainter

### Community 92 - "bienvenida_animada_test.dart"
Cohesion: 0.14
Nodes (12): alTerminar, build, _cargaDatos, createState, _datos, dispose, _escuchas, _Espera (+4 more)

### Community 93 - "authNotifierProvider"
Cohesion: 0.32
Nodes (5): authNotifierProvider, build, build, build, _cerrarSesion

### Community 95 - "package:flutter/material.dart"
Cohesion: 0.18
Nodes (7): iconoCategoria, imagenDeSena, normalizarBusqueda, tildes, toLowerCase, main, _opcion

### Community 96 - "main.dart"
Cohesion: 0.29
Nodes (3): build, main, MyApp

### Community 99 - "perfil_provider.dart"
Cohesion: 0.25
Nodes (4): Usuario, obtenerUsuario, repo, watch

### Community 101 - "hand_landmarks_painter.dart"
Cohesion: 0.22
Nodes (6): color, _connections, hands, isFrontCamera, paint, shouldRepaint

### Community 103 - "package:miapp/features/perfil/models/usuario_model.dart"
Cohesion: 0.22
Nodes (5): main, _usuario, conRacha, hoy, main

### Community 104 - "List"
Cohesion: 0.33
Nodes (4): build, children, CuadriculaDos, espacio

### Community 215 - "racha_celebracion.dart"
Cohesion: 0.07
Nodes (28): _anim, anterior, _apagado, avisarSiPerdioRacha, build, _caida, _cambioNumero, clave (+20 more)

### Community 252 - "proyecto.md"
Cohesion: 0.08
Nodes (24): 10. Pruebas y criterios de aceptación, 11. Estrategia de implementación, 12. Instrucciones para el agente de programación, 13. Evolución futura, 1. Objetivo del producto, 2. Usuarios y necesidad, 3. Alcance del MVP, 4.1 Inicio (+16 more)

## Ambiguous Edges - Review These
- `claude.md (empty project notes)` → `Miapp - Diccionario de Lengua de Senas`  [AMBIGUOUS]
  claude.md · relation: conceptually_related_to

## Knowledge Gaps
- **874 isolated node(s):** `SupabaseConfig`, `url`, `anonKey`, `claveSesion`, `statusCode` (+869 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 1110 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Win32Window` connect `Windows Plugin Registry` to `Windows Flutter Window`, `Win32 Message Handling`, `Win32 Window Lifecycle`, `string`, `Point`?**
  _High betweenness centrality (0.032) - this node is a cross-community bridge._
- **What connects `SupabaseConfig`, `url`, `anonKey` to the rest of the system?**
  _874 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `auth_providers.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.14285714285714285 - nodes in this community are weakly interconnected._
- **Why does `UsuarioUpdate` connect `test_seguridad.py` to `validar_fecha_local`, `dependencies.py`?**
  _High betweenness centrality (0.014) - this node is a cross-community bridge._
- **Should `iOS/macOS App Delegates` be split into smaller, more focused modules?**
  _Cohesion score 0.05496828752642706 - nodes in this community are weakly interconnected._
- **Why does `AuthState` connect `auth_google_test.dart` to `auth_providers.dart`, `register_page.dart`, `login_page.dart`?**
  _High betweenness centrality (0.013) - this node is a cross-community bridge._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `claude.md (empty project notes)` and `Miapp - Diccionario de Lengua de Senas`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._