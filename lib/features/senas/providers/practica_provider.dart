import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/features/senas/models/landmark_model.dart';
import 'package:miapp/features/senas/models/reconocimiento_sena_model.dart';
import 'package:miapp/features/senas/providers/practica_state.dart';
import 'package:miapp/features/senas/services/audio_numeros_service.dart';
import 'package:miapp/features/senas/services/camera_detection_service.dart';
import 'package:miapp/features/senas/services/clasificador_knn_service.dart';
import 'package:miapp/features/senas/services/clasificador_letras_service.dart';
import 'package:miapp/features/senas/services/clasificador_numeros_service.dart';
import 'package:miapp/features/senas/services/estabilizador_reconocimiento_service.dart';

/// Provider que provee una instancia aislada de [CameraDetectionService]
/// con ciclo de vida automático (autoDispose).
final cameraDetectionServiceProvider =
    Provider.autoDispose<CameraDetectionService>((ref) {
      final service = CameraDetectionService();
      ref.onDispose(() => service.dispose());
      return service;
    });

final audioNumerosServiceProvider = Provider.autoDispose<AudioNumerosService>((
  ref,
) {
  final service = AudioNumerosService();
  ref.onDispose(service.dispose);
  return service;
});

/// Notifier responsable de orquestar el flujo de la práctica,
/// manteniendo la lógica de negocio y del hardware separada de la vista UI.
class PracticaNotifier extends StateNotifier<PracticaState> {
  PracticaNotifier(
    this._cameraService,
    this._audio, {
    EstabilizadorReconocimiento? estabilizador,
  }) : _estabilizador = estabilizador ?? EstabilizadorReconocimiento(),
       super(const PracticaState()) {
    _initHandsListener();
  }

  final CameraDetectionService _cameraService;
  final AudioNumerosService _audio;
  final EstabilizadorReconocimiento _estabilizador;
  final _clasificador = const ClasificadorNumeros();
  final _letras = const ClasificadorLetras();

  /// Se carga en [initialize]; mientras tanto sus letras no se reconocen.
  ClasificadorKnn? _knn;
  StreamSubscription<List<List<Offset>>>? _handsSubscription;
  StreamSubscription<List<List<Landmark>>>? _landmarksSubscription;
  Object? _ultimoAnunciado;

  /// Mano suavizada entre fotogramas; null al perder la mano.
  List<Landmark>? _suavizada;

  // Modo captura (solo debug): etiqueta y fotogramas vistos desde que empezó.
  String? _etiquetaCaptura;
  int _framesCaptura = 0;

  /// Si no es null, solo se acepta esta seña: `int` para un número o `String`
  /// para una letra (práctica de una seña).
  Object? _objetivo;

  void _initHandsListener() {
    _handsSubscription = _cameraService.handsStream.listen((hands) {
      if (mounted) {
        state = state.copyWith(detectedHands: hands);
      }
    });
  }

  /// Inicia o detiene la clasificación de señas sobre el stream de landmarks.
  void toggleReconocimiento({Object? objetivo}) {
    if (state.reconociendo) {
      _landmarksSubscription?.cancel();
      _landmarksSubscription = null;
      _estabilizador.reiniciar();
      _ultimoAnunciado = null;
      _suavizada = null;
      _etiquetaCaptura = null;
      state = state.copyWith(
        resultado: ResultadoReconocimiento.detenido,
        extensiones: const [],
        muestrasRestantes: 0,
      );
    } else if (state.isReady) {
      _objetivo = objetivo;
      _landmarksSubscription = _cameraService.landmarksStream.listen(
        _procesarManos,
      );
      state = state.copyWith(
        resultado: const ResultadoReconocimiento(EstadoReconocimiento.sinMano),
      );
    }
  }

  void _procesarManos(List<List<Landmark>> manos) {
    if (!mounted) return;
    final size = state.controller?.value.previewSize;
    // previewSize viene en horizontal; la imagen ya está girada a vertical.
    final aspecto = size == null ? 1.0 : size.height / size.width;
    final cruda = manoPrincipal(manos);
    final parcial = cruda != null && ClasificadorNumeros.esParcial(cruda);
    _capturar(cruda, parcial, aspecto);
    _suavizada = cruda == null || parcial || cruda.length < 21
        ? null
        : suavizar(_suavizada, cruda);
    final mano = _suavizada ?? cruda;
    final ext = mano == null || parcial || mano.length < 21
        ? const <double>[]
        : _clasificador.extensiones(mano, aspecto: aspecto);
    final cont = ext.isEmpty
        ? const <double>[]
        : _clasificador.contactos(mano!, aspecto: aspecto);
    // Con objetivo solo se puntúa esa seña; cualquier otro queda en null.
    final clasificacion = ext.isEmpty
        ? null
        : switch (_objetivo) {
            // Con muestras grabadas mandan ellas: las reglas, hechas sin
            // manos reales, toleraban dedos fuera de lugar.
            final String letra when ClasificadorKnn.letras.contains(letra) =>
              _knn?.puntuar(letra, mano!, aspecto: aspecto),
            final String letra => _letras.puntuar(
              letra,
              mano!,
              aspecto: aspecto,
            ),
            final int n when ClasificadorKnn.numeros.contains(n) => switch (_knn
                ?.puntuar('num-$n', mano!, aspecto: aspecto)) {
              final c? => ClasificacionSena(n, c.confianza),
              null => null,
            },
            final int? n => _clasificador.desdeExtensiones(
              ext,
              contactos: cont,
              solo: n,
            ),
            _ => null,
          };
    final resultado = _estabilizador.actualizar(
      hayMano: mano != null,
      parcial: parcial,
      clasificacion: clasificacion,
    );

    // Un audio por seña confirmada; se rearma al perder la mano.
    if (resultado.confirmada && resultado.sena != _ultimoAnunciado) {
      _ultimoAnunciado = resultado.sena;
      // Solo hay audios de números.
      if (resultado.sena case final int n) _audio.reproducir(n);
    } else if (resultado.estado == EstadoReconocimiento.sinMano) {
      _ultimoAnunciado = null;
    }
    state = state.copyWith(
      resultado: resultado,
      extensiones: [...ext, ...cont],
    );
  }

  /// Modo captura (solo debug): imprime en el log [total] muestras de la mano
  /// con la etiqueta [etiqueta], una cada 3 fotogramas para que varíen. Se
  /// leen con `adb logcat -s flutter | grep MUESTRA`.
  void grabarMuestras(String etiqueta, {int total = 30}) {
    if (!kDebugMode || !state.reconociendo) return;
    _etiquetaCaptura = etiqueta;
    _framesCaptura = 0;
    state = state.copyWith(muestrasRestantes: total);
  }

  void _capturar(List<Landmark>? mano, bool parcial, double aspecto) {
    final etiqueta = _etiquetaCaptura;
    if (etiqueta == null || mano == null || parcial || mano.length < 21) {
      return;
    }
    if (_framesCaptura++ % 3 != 0) return;
    debugPrint(
      'MUESTRA ${jsonEncode({
        'sena': etiqueta,
        'frontal': state.isFrontCamera,
        'aspecto': double.parse(aspecto.toStringAsFixed(4)),
        'p': [
          for (final l in mano)
            for (final v in [l.x, l.y, l.z]) double.parse(v.toStringAsFixed(4)),
        ],
      })}',
    );
    final restantes = state.muestrasRestantes - 1;
    if (restantes <= 0) _etiquetaCaptura = null;
    state = state.copyWith(muestrasRestantes: restantes);
  }

  /// Inicializa la cámara y la detección con MediaPipe.
  Future<void> initialize() async {
    if (state.isReady || state.status == PracticaStatus.loading) return;

    state = state.copyWith(status: PracticaStatus.loading, errorMessage: null);

    try {
      _knn ??= ClasificadorKnn.desdeJson(
        await rootBundle.loadString(ClasificadorKnn.asset),
      );
      await _cameraService.initialize();
      if (mounted) {
        state = state.copyWith(
          status: PracticaStatus.ready,
          controller: _cameraService.controller,
          isFrontCamera: _cameraService.isFrontCamera,
          canSwitchCamera: _cameraService.canSwitchCamera,
        );
      }
    } on CameraDetectionException catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: PracticaStatus.error,
          errorMessage: e.message,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: PracticaStatus.error,
          errorMessage: 'Ocurrió un error inesperado al iniciar la cámara: $e',
        );
      }
    }
  }

  /// Alterna entre la cámara frontal y la trasera.
  Future<void> toggleCamera() async {
    if (!state.canSwitchCamera || state.isSwitchingCamera || !state.isReady) {
      return;
    }

    state = state.copyWith(status: PracticaStatus.switchingCamera);

    try {
      await _cameraService.toggleCamera();
      if (mounted) {
        state = state.copyWith(
          status: PracticaStatus.ready,
          controller: _cameraService.controller,
          isFrontCamera: _cameraService.isFrontCamera,
        );
      }
    } on CameraDetectionException catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: PracticaStatus.error,
          errorMessage: e.message,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: PracticaStatus.error,
          errorMessage: 'Error al cambiar de cámara: $e',
        );
      }
    }
  }

  /// Gestiona el ciclo de vida de la aplicación para pausar o reanudar el hardware.
  void handleAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.inactive ||
        lifecycle == AppLifecycleState.paused) {
      _cameraService.pauseStream();
    } else if (lifecycle == AppLifecycleState.resumed) {
      _cameraService.resumeStream();
    }
  }

  @override
  void dispose() {
    _handsSubscription?.cancel();
    _landmarksSubscription?.cancel();
    super.dispose();
  }
}

/// La mano más grande (la más cercana a la cámara); MediaPipe no ordena las
/// manos, así que `first` podía ser la de fondo.
@visibleForTesting
List<Landmark>? manoPrincipal(List<List<Landmark>> manos) {
  double area(List<Landmark> m) {
    final xs = m.map((l) => l.x), ys = m.map((l) => l.y);
    return (xs.reduce(math.max) - xs.reduce(math.min)) *
        (ys.reduce(math.max) - ys.reduce(math.min));
  }

  final validas = manos.where((m) => m.isNotEmpty);
  return validas.isEmpty
      ? null
      : validas.reduce((a, b) => area(a) >= area(b) ? a : b);
}

/// Media móvil exponencial por punto: quita el temblor de MediaPipe que hacía
/// saltar los puntajes alrededor de 0.5. [alfa] alto sigue más rápido a la mano.
@visibleForTesting
List<Landmark> suavizar(
  List<Landmark>? previa,
  List<Landmark> actual, {
  double alfa = 0.5,
}) {
  if (previa == null || previa.length != actual.length) return actual;
  double mezcla(double a, double b) => a + (b - a) * alfa;
  return [
    for (var i = 0; i < actual.length; i++)
      Landmark(
        x: mezcla(previa[i].x, actual[i].x),
        y: mezcla(previa[i].y, actual[i].y),
        z: mezcla(previa[i].z, actual[i].z),
      ),
  ];
}

/// Provider que expone el estado y los métodos de la práctica a la UI.
final practicaProvider =
    StateNotifierProvider.autoDispose<PracticaNotifier, PracticaState>((ref) {
      final service = ref.watch(cameraDetectionServiceProvider);
      return PracticaNotifier(service, ref.watch(audioNumerosServiceProvider));
    });
