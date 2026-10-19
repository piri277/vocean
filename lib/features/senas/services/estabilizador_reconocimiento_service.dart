import 'dart:collection';

import 'package:miapp/features/senas/models/reconocimiento_numero_model.dart';

/// Suaviza las clasificaciones por fotograma y solo confirma un número tras
/// observar suficientes fotogramas consistentes en una ventana deslizante.
class EstabilizadorReconocimiento {
  EstabilizadorReconocimiento({
    this.umbralConfianza = 0.75,
    this.ventana = 10,
    this.framesConfirmacion = 6,
  }) : assert(framesConfirmacion * 2 > ventana, 'evita empates al confirmar'),
       assert(framesConfirmacion <= ventana);

  /// Confianza mínima de un fotograma para contar como evidencia.
  final double umbralConfianza;
  final int ventana;
  final int framesConfirmacion;

  // null = fotograma sin evidencia (sin mano, parcial o bajo el umbral).
  final Queue<ClasificacionNumero?> _frames = Queue();
  bool _hayMano = false;
  bool _parcial = false;

  void reiniciar() {
    _frames.clear();
    _hayMano = false;
    _parcial = false;
  }

  ResultadoReconocimiento actualizar({
    required bool hayMano,
    bool parcial = false,
    ClasificacionNumero? clasificacion,
  }) {
    _hayMano = hayMano;
    _parcial = parcial;
    final valida =
        hayMano &&
        !parcial &&
        clasificacion != null &&
        clasificacion.confianza >= umbralConfianza;
    _frames.addLast(valida ? clasificacion : null);
    if (_frames.length > ventana) _frames.removeFirst();

    final conteo = <int, List<double>>{};
    for (final f in _frames.whereType<ClasificacionNumero>()) {
      (conteo[f.numero] ??= []).add(f.confianza);
    }
    final mejor = conteo.entries.isEmpty
        ? null
        : conteo.entries.reduce(
            (a, b) => a.value.length >= b.value.length ? a : b,
          );

    if (mejor != null) {
      final confianza =
          mejor.value.reduce((a, b) => a + b) / mejor.value.length;
      if (mejor.value.length >= framesConfirmacion) {
        return ResultadoReconocimiento(
          EstadoReconocimiento.confirmada,
          numero: mejor.key,
          confianza: confianza,
        );
      }
      if (hayMano && mejor.value.length * 2 >= framesConfirmacion) {
        return ResultadoReconocimiento(
          EstadoReconocimiento.analizando,
          numero: mejor.key,
          confianza: confianza,
        );
      }
    }
    if (!_hayMano) {
      return const ResultadoReconocimiento(EstadoReconocimiento.sinMano);
    }
    if (_parcial) {
      return const ResultadoReconocimiento(EstadoReconocimiento.manoParcial);
    }
    return const ResultadoReconocimiento(EstadoReconocimiento.noReconocida);
  }
}
