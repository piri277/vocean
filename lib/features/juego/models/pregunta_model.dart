import 'package:miapp/features/senas/models/sena_model.dart';

/// Pregunta que se plantea al jugador en la práctica de señas.
class Pregunta {
  const Pregunta({
    required this.secuenciaSenas,
    required this.opciones,
    required this.respuestaCorrecta,
    this.respuestaUsuario,
    this.tiempoLimite,
  });

  final List<Sena> secuenciaSenas;
  final List<String> opciones;
  final String respuestaCorrecta;
  final String? respuestaUsuario;
  final Duration? tiempoLimite;

  bool esCorrecta(String opcion) {
    // TODO: definir la validación real de respuesta frente a la opción.
    throw UnimplementedError('pendiente');
  }
}
