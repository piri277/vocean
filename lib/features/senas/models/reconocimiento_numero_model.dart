/// Fase del reconocimiento tras el suavizado temporal.
enum EstadoReconocimiento {
  /// Reconocimiento detenido por el usuario.
  detenido,
  sinMano,

  /// Mano cortada por el borde de la imagen: no se clasifica.
  manoParcial,

  /// Hay un candidato, pero aún sin fotogramas consistentes suficientes.
  analizando,

  /// Hay mano pero ningún número alcanza la evidencia mínima.
  noReconocida,
  confirmada,
}

/// Resultado de clasificar un solo fotograma.
class ClasificacionNumero {
  const ClasificacionNumero(this.numero, this.confianza);

  final int numero;

  /// 0.0 a 1.0. Es un puntaje geométrico, no una probabilidad calibrada.
  final double confianza;
}

/// Resultado estable que consume la UI.
class ResultadoReconocimiento {
  const ResultadoReconocimiento(this.estado, {this.numero, this.confianza = 0});

  static const detenido = ResultadoReconocimiento(
    EstadoReconocimiento.detenido,
  );

  final EstadoReconocimiento estado;

  /// Solo no nulo cuando [estado] es `analizando` o `confirmada`.
  final int? numero;
  final double confianza;

  bool get confirmada => estado == EstadoReconocimiento.confirmada;
}
