import 'dart:math' as math;

import 'package:miapp/features/senas/models/landmark_model.dart';
import 'package:miapp/features/senas/models/posicion_mano_model.dart';
import 'package:miapp/features/senas/models/resultado_validacion_model.dart';

/// Valida una captura en vivo contra la referencia de una seña.
class ValidadorPosicion {
  ResultadoValidacion validar(
    List<Landmark> capturados,
    PosicionMano referencia,
  ) {
    if (capturados.isEmpty) {
      return const ResultadoValidacion(
        correcto: false,
        sugerencia: 'No se detectó ninguna mano en la cámara.',
      );
    }

    final puntos = capturados.length >= 21
        ? capturados.sublist(0, 21)
        : capturados;

    if (puntos.length < 21) {
      return const ResultadoValidacion(
        correcto: false,
        sugerencia: 'Acerca la mano a la cámara para tener todos los puntos.',
      );
    }

    final puntosClaves = referencia.landmarksClave
        .where((index) => index >= 0 && index < puntos.length)
        .toList();

    if (puntosClaves.length < 3) {
      return const ResultadoValidacion(
        correcto: false,
        sugerencia: 'La mano no está bien alineada con la cámara.',
      );
    }

    final distanciaIndiceMedio = _distanciaEntre(puntos[8], puntos[12]);
    final anguloPulgar = _anguloEntre(puntos[0], puntos[4], puntos[8]);

    final escalaDistancia = math.max(referencia.distanciaIndiceMedio, 0.01);
    final errorDistancia = (distanciaIndiceMedio / escalaDistancia).abs();
    final errorAngulo = (anguloPulgar - referencia.anguloPulgar).abs();

    final puntosDetectados = puntosClaves.length;
    final presencia =
        puntosDetectados / math.max(referencia.landmarksClave.length, 1);

    final coincide =
        presencia >= 0.7 &&
        errorDistancia <= 2.0 &&
        errorAngulo <= math.max(25.0, referencia.anguloPulgar * 0.8 + 10.0);

    if (coincide) {
      return const ResultadoValidacion(
        correcto: true,
        sugerencia: 'Muy bien. La posición de la mano coincide.',
      );
    }

    final sugerencia = errorAngulo > 18
        ? 'Ajusta más el pulgar para acercarte a la referencia.'
        : 'Mantén la mano más abierta y centrada en la cámara.';

    return ResultadoValidacion(correcto: false, sugerencia: sugerencia);
  }

  double _distanciaEntre(Landmark a, Landmark b) => math.sqrt(
    math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2) + math.pow(a.z - b.z, 2),
  );

  double _anguloEntre(Landmark base, Landmark punta1, Landmark punta2) {
    final v1 = _vector(base, punta1);
    final v2 = _vector(base, punta2);

    final numerador = v1.x * v2.x + v1.y * v2.y;
    final modulo = _modulo(v1) * _modulo(v2);

    if (modulo == 0) return 0;

    final coseno = (numerador / modulo).clamp(-1, 1);
    return math.acos(coseno) * 180 / math.pi;
  }

  ({double x, double y}) _vector(Landmark origen, Landmark destino) =>
      (x: destino.x - origen.x, y: destino.y - origen.y);

  double _modulo(({double x, double y}) vector) =>
      math.sqrt(math.pow(vector.x, 2) + math.pow(vector.y, 2));
}
