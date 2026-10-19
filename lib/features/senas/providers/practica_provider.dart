import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/features/senas/models/landmark_model.dart';
import 'package:miapp/features/senas/models/reconocimiento_numero_model.dart';
import 'package:miapp/features/senas/providers/practica_state.dart';
import 'package:miapp/features/senas/services/audio_numeros_service.dart';
import 'package:miapp/features/senas/services/camera_detection_service.dart';
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
  StreamSubscription<List<List<Offset>>>? _handsSubscription;
  StreamSubscription<List<List<Landmark>>>? _landmarksSubscription;
  int? _ultimoAnunciado;

  /// Si no es null, solo se acepta este número (práctica de una seña).
  int? _objetivo;

  void _initHandsListener() {
    _handsSubscription = _cameraService.handsStream.listen((hands) {
      if (mounted) {
        state = state.copyWith(detectedHands: hands);
      }
    });
  }

  /// Inicia o detiene la clasificación de números sobre el stream de landmarks.
  void toggleReconocimiento({int? objetivo}) {
    if (state.reconociendo) {
      _landmarksSubscription?.cancel();
      _landmarksSubscription = null;
      _estabilizador.reiniciar();
      _ultimoAnunciado = null;
      state = state.copyWith(
        resultado: ResultadoReconocimiento.detenido,
        extensiones: const [],
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
    final mano = manos.isEmpty ? null : manos.first;
    final parcial = mano != null && ClasificadorNumeros.esParcial(mano);
    final ext = mano == null || parcial || mano.length < 21
        ? const <double>[]
        : _clasificador.extensiones(mano, aspecto: aspecto);
    final clasificacion = ext.isEmpty
        ? null
        : _clasificador.desdeExtensiones(ext);
    final resultado = _estabilizador.actualizar(
      hayMano: mano != null,
      parcial: parcial,
      // Con objetivo, cualquier otro número cuenta como no reconocido.
      clasificacion: _objetivo == null || clasificacion?.numero == _objetivo
          ? clasificacion
          : null,
    );

    // Un audio por seña confirmada; se rearma al perder la mano.
    if (resultado.confirmada && resultado.numero != _ultimoAnunciado) {
      _ultimoAnunciado = resultado.numero;
      _audio.reproducir(resultado.numero!);
    } else if (resultado.estado == EstadoReconocimiento.sinMano) {
      _ultimoAnunciado = null;
    }
    state = state.copyWith(resultado: resultado, extensiones: ext);
  }

  /// Inicializa la cámara y la detección con MediaPipe.
  Future<void> initialize() async {
    if (state.isReady || state.status == PracticaStatus.loading) return;

    state = state.copyWith(status: PracticaStatus.loading, errorMessage: null);

    try {
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

/// Provider que expone el estado y los métodos de la práctica a la UI.
final practicaProvider =
    StateNotifierProvider.autoDispose<PracticaNotifier, PracticaState>((ref) {
      final service = ref.watch(cameraDetectionServiceProvider);
      return PracticaNotifier(service, ref.watch(audioNumerosServiceProvider));
    });
