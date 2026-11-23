import 'dart:collection';

import 'package:miapp/features/senas/models/reconocimiento_sena_model.dart';

/// Suaviza las clasificaciones por fotograma y solo confirma una seña tras
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

  // null = fotograma sin candidato (sin mano o parcial). Los que quedan bajo
  // el umbral se guardan: no confirman, pero cuentan para `analizando`.
  final Queue<ClasificacionSena?> _frames = Queue();
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
    ClasificacionSena? clasificacion,
  }) {
    _hayMano = hayMano;
    _parcial = parcial;
    _frames.addLast(hayMano && !parcial ? clasificacion : null);
    if (_frames.length > ventana) _frames.removeFirst();

    ({Object sena, List<double> conf})? mejorDe(
      Iterable<ClasificacionSena> frames,
    ) {
      final conteo = <Object, List<double>>{};
      for (final f in frames) {
        (conteo[f.sena] ??= []).add(f.confianza);
      }
      if (conteo.isEmpty) return null;
      final e = conteo.entries.reduce(
        (a, b) => a.value.length >= b.value.length ? a : b,
      );
      return (sena: e.key, conf: e.value);
    }

    double media(List<double> c) => c.reduce((a, b) => a + b) / c.length;
    final todos = _frames.whereType<ClasificacionSena>();
    final fuerte = mejorDe(todos.where((f) => f.confianza >= umbralConfianza));
    if (fuerte != null && fuerte.conf.length >= framesConfirmacion) {
      return ResultadoReconocimiento(
        EstadoReconocimiento.confirmada,
        sena: fuerte.sena,
        confianza: media(fuerte.conf),
      );
    }
    final cualquiera = mejorDe(todos);
    if (hayMano &&
        cualquiera != null &&
        cualquiera.conf.length * 2 >= framesConfirmacion) {
      return ResultadoReconocimiento(
        EstadoReconocimiento.analizando,
        sena: cualquiera.sena,
        confianza: media(cualquiera.conf),
      );
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
