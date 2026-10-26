/// Fase del reconocimiento tras el suavizado temporal.
enum EstadoReconocimiento {
  /// Reconocimiento detenido por el usuario.
  detenido,
  sinMano,

  /// Mano cortada por el borde de la imagen: no se clasifica.
  manoParcial,

  /// Hay un candidato, pero aún sin fotogramas consistentes suficientes.
  analizando,

  /// Hay mano pero ninguna seña alcanza la evidencia mínima.
  noReconocida,
  confirmada,
}

/// Resultado de clasificar un solo fotograma.
class ClasificacionSena {
  const ClasificacionSena(this.sena, this.confianza);

  /// `int` para números y `String` (minúscula) para letras.
  final Object sena;

  /// 0.0 a 1.0. Es un puntaje geométrico, no una probabilidad calibrada.
  final double confianza;
}

/// Resultado estable que consume la UI.
class ResultadoReconocimiento {
  const ResultadoReconocimiento(this.estado, {this.sena, this.confianza = 0});

  static const detenido = ResultadoReconocimiento(
    EstadoReconocimiento.detenido,
  );

  final EstadoReconocimiento estado;

  /// Solo no nulo cuando [estado] es `analizando` o `confirmada`.
  final Object? sena;
  final double confianza;

  bool get confirmada => estado == EstadoReconocimiento.confirmada;
}
