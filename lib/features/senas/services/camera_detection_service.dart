import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hand_landmarker/hand_landmarker.dart' as hand_landmarker;
import 'package:miapp/features/senas/models/landmark_model.dart';

/// Excepción base para errores relacionados con la cámara y detección de señas.
sealed class CameraDetectionException implements Exception {
  const CameraDetectionException(this.message);
  final String message;

  @override
  String toString() => message;
}

class UnsupportedPlatformException extends CameraDetectionException {
  const UnsupportedPlatformException([
    super.message = 'MediaPipe Hand Landmarker requiere Android.',
  ]);
}

class CameraPermissionException extends CameraDetectionException {
  const CameraPermissionException([
    super.message = 'Permiso de cámara denegado.',
  ]);
}

class NoCameraAvailableException extends CameraDetectionException {
  const NoCameraAvailableException([
    super.message = 'No se encontraron cámaras disponibles en el dispositivo.',
  ]);
}

class CameraInitializationException extends CameraDetectionException {
  const CameraInitializationException(super.message);
}

/// Servicio desacoplado encargado de gestionar el hardware de la cámara,
/// el ciclo de vida del controlador, el stream de imágenes y la integración
/// nativa con MediaPipe HandLandmarker.
class CameraDetectionService {
  CameraController? _cameraController;
  CameraDescription? _activeCamera;
  List<CameraDescription> _cameras = const [];

  hand_landmarker.HandLandmarkerPlugin? _handLandmarker;
  StreamSubscription<List<hand_landmarker.Hand>>? _landmarkSubscription;

  final _handsStreamController =
      StreamController<List<List<Offset>>>.broadcast();

  final _landmarksStreamController =
      StreamController<List<List<Landmark>>>.broadcast();

  bool _isProcessingFrame = false;
  bool _isStreaming = false;
  bool _isDisposed = false;

  /// Stream reactivo que emite las manos detectadas normalizadas (0.0 a 1.0).
  Stream<List<List<Offset>>> get handsStream => _handsStreamController.stream;

  /// Manos con landmarks crudos (x, y, z sin recortar) para clasificación.
  Stream<List<List<Landmark>>> get landmarksStream =>
      _landmarksStreamController.stream;

  /// Controlador activo de la cámara (para pasar al widget `CameraPreview`).
  CameraController? get controller => _cameraController;

  /// Descripción de la cámara en uso (frontal, trasera, etc.).
  CameraDescription? get activeCamera => _activeCamera;

  /// Indica si la cámara actual es la frontal.
  bool get isFrontCamera =>
      _activeCamera?.lensDirection == CameraLensDirection.front;

  /// Indica si el dispositivo cuenta con más de una cámara para alternar.
  bool get canSwitchCamera => _cameras.length > 1;

  /// Inicializa la cámara y el motor de MediaPipe.
  ///
  /// Lanza subtipos de [CameraDetectionException] en caso de error.
  Future<void> initialize({
    CameraLensDirection preferredLens = CameraLensDirection.front,
  }) async {
    if (!Platform.isAndroid) {
      throw const UnsupportedPlatformException();
    }

    try {
      _cameras = await availableCameras();
    } catch (e) {
      throw CameraInitializationException('Error al consultar las cámaras: $e');
    }

    if (_cameras.isEmpty) {
      throw const NoCameraAvailableException();
    }

    final selectedCamera = _cameras.firstWhere(
      (c) => c.lensDirection == preferredLens,
      orElse: () => _cameras.first,
    );

    await _startCamera(selectedCamera);
  }

  /// Inicia el controlador de la cámara especificada y configura MediaPipe.
  Future<void> _startCamera(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset
          .medium, // Reducido para óptimo rendimiento de FPS y temperatura
      enableAudio: false,
    );

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      if (e.code == 'CameraAccessDenied' ||
          e.code == 'CameraAccessDeniedWithoutPrompt' ||
          e.code == 'CameraAccessRestricted') {
        throw const CameraPermissionException(
          'El acceso a la cámara fue denegado. Concede los permisos en los ajustes.',
        );
      }
      throw CameraInitializationException(
        'Error al inicializar la cámara: ${e.description ?? e.code}',
      );
    }

    if (_isDisposed) {
      await controller.dispose();
      return;
    }

    // Inicializamos el plugin de MediaPipe con aceleración por GPU.
    _handLandmarker = hand_landmarker.HandLandmarkerPlugin.create(
      numHands: 2,
      minHandDetectionConfidence: 0.5,
      delegate: hand_landmarker.HandLandmarkerDelegate.gpu,
    );

    _landmarkSubscription = _handLandmarker!.landmarkStream.listen((hands) {
      if (_isDisposed) return;

      final mapped = hands
          .map(
            (hand) => hand.landmarks
                .map(
                  (point) =>
                      Offset(point.x.clamp(0.0, 1.0), point.y.clamp(0.0, 1.0)),
                )
                .toList(),
          )
          .toList();

      if (!_handsStreamController.isClosed) {
        _handsStreamController.add(mapped);
      }
      if (!_landmarksStreamController.isClosed) {
        _landmarksStreamController.add(
          hands
              .map(
                (h) => h.landmarks
                    .map((p) => Landmark(x: p.x, y: p.y, z: p.z))
                    .toList(),
              )
              .toList(),
        );
      }
    });

    await controller.startImageStream(_processCameraImage);
    _isStreaming = true;

    _activeCamera = camera;
    _cameraController = controller;
  }

  /// Procesa los frames de la cámara enviándolos a MediaPipe con descarte
  /// de frames concurrentes para evitar bloqueos del hilo principal.
  void _processCameraImage(CameraImage image) {
    if (_isProcessingFrame ||
        _handLandmarker == null ||
        _cameraController == null ||
        _isDisposed) {
      return;
    }

    _isProcessingFrame = true;
    try {
      _handLandmarker!.processFrame(
        image,
        _cameraController!.description.sensorOrientation,
      );
    } catch (_) {
      // Ignoramos errores transitorios de frames individuales.
    } finally {
      _isProcessingFrame = false;
    }
  }

  /// Alterna entre la cámara frontal y la trasera de manera segura.
  Future<void> toggleCamera() async {
    if (_isDisposed || _cameras.length < 2 || _cameraController == null) {
      return;
    }

    final currentIndex = _activeCamera == null
        ? 0
        : _cameras.indexOf(_activeCamera!);
    final nextIndex = (currentIndex + 1) % _cameras.length;
    final nextCamera = _cameras[nextIndex];

    await _stopCurrentCamera();
    await _startCamera(nextCamera);
  }

  /// Detiene el stream y libera el controlador actual antes de cambiar de cámara.
  Future<void> _stopCurrentCamera() async {
    await _landmarkSubscription?.cancel();
    _landmarkSubscription = null;

    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      try {
        await _cameraController!.stopImageStream();
      } catch (_) {}
    }
    _isStreaming = false;

    _handLandmarker?.dispose();
    _handLandmarker = null;

    await _cameraController?.dispose();
    _cameraController = null;
  }

  /// Pausa el stream de la cámara (por ejemplo, cuando la app pasa a segundo plano).
  Future<void> pauseStream() async {
    if (_isStreaming &&
        _cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      try {
        await _cameraController!.stopImageStream();
        _isStreaming = false;
      } catch (_) {}
    }
  }

  /// Reanuda el stream de la cámara (cuando la app vuelve al primer plano).
  Future<void> resumeStream() async {
    if (!_isStreaming &&
        _cameraController != null &&
        _cameraController!.value.isInitialized &&
        !_cameraController!.value.isStreamingImages) {
      try {
        await _cameraController!.startImageStream(_processCameraImage);
        _isStreaming = true;
      } catch (_) {}
    }
  }

  /// Libera todos los recursos del hardware y suscripciones de manera definitiva.
  Future<void> dispose() async {
    _isDisposed = true;
    await _stopCurrentCamera();
    await _handsStreamController.close();
    await _landmarksStreamController.close();
  }
}
