import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:miapp/features/senas/models/reconocimiento_numero_model.dart';

/// Estados posibles de la pantalla de práctica.
enum PracticaStatus { initial, loading, ready, switchingCamera, error }

/// Estado inmutable para la vista de práctica de señas.
class PracticaState {
  const PracticaState({
    this.status = PracticaStatus.initial,
    this.controller,
    this.detectedHands = const [],
    this.isFrontCamera = true,
    this.canSwitchCamera = false,
    this.errorMessage,
    this.resultado = ResultadoReconocimiento.detenido,
    this.extensiones = const [],
  });

  final PracticaStatus status;
  final CameraController? controller;
  final List<List<Offset>> detectedHands;
  final bool isFrontCamera;
  final bool canSwitchCamera;
  final String? errorMessage;
  final ResultadoReconocimiento resultado;

  /// Puntaje 0-1 por dedo del último fotograma (pulgar a meñique), para calibrar.
  final List<double> extensiones;

  bool get isLoading =>
      status == PracticaStatus.initial || status == PracticaStatus.loading;
  bool get isReady => status == PracticaStatus.ready && controller != null;
  bool get isSwitchingCamera => status == PracticaStatus.switchingCamera;
  bool get hasError => status == PracticaStatus.error;
  bool get reconociendo => resultado.estado != EstadoReconocimiento.detenido;
  bool get hasHandsDetected => detectedHands.isNotEmpty;

  PracticaState copyWith({
    PracticaStatus? status,
    CameraController? controller,
    List<List<Offset>>? detectedHands,
    bool? isFrontCamera,
    bool? canSwitchCamera,
    String? errorMessage,
    ResultadoReconocimiento? resultado,
    List<double>? extensiones,
  }) {
    return PracticaState(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      detectedHands: detectedHands ?? this.detectedHands,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      canSwitchCamera: canSwitchCamera ?? this.canSwitchCamera,
      errorMessage: errorMessage ?? this.errorMessage,
      resultado: resultado ?? this.resultado,
      extensiones: extensiones ?? this.extensiones,
    );
  }
}
