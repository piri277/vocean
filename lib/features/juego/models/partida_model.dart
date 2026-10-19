import 'package:miapp/features/juego/models/dificultad_model.dart';
import 'package:miapp/features/juego/models/pregunta_model.dart';
import 'package:miapp/features/juego/models/resumen_partida_model.dart';

/// Partida en curso o finalizada del modo juego.
class Partida {
  Partida({
    required this.id,
    required this.dificultad,
    required this.puntuacion,
    required this.rachaActual,
    required this.rachaMaxima,
    required this.xpGanado,
    required this.fecha,
    required this.preguntas,
  });

  final String id;
  final Dificultad dificultad;
  final int puntuacion;
  final int rachaActual;
  final int rachaMaxima;
  final int xpGanado;
  final DateTime fecha;
  final List<Pregunta> preguntas;

  void registrarRespuesta(Pregunta pregunta, String? opcion) {
    // TODO: actualizar puntuación, racha y estado de la pregunta.
    throw UnimplementedError('pendiente');
  }

  bool get haTerminado {
    // TODO: definir la condición de fin de partida.
    throw UnimplementedError('pendiente');
  }

  ResumenPartida resumen() {
    // TODO: crear el resumen final de la partida.
    throw UnimplementedError('pendiente');
  }
}
