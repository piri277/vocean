import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/senas/models/landmark_model.dart';
import 'package:miapp/features/senas/models/posicion_mano_model.dart';
import 'package:miapp/features/senas/services/validador_posicion_service.dart';

void main() {
  group('ValidadorPosicion', () {
    test('acepta una mano que coincide con la referencia de la seña', () {
      final referencia = const PosicionMano(
        landmarksClave: [0, 4, 8, 12, 16, 20],
        anguloPulgar: 30,
        distanciaIndiceMedio: 0.32,
      );

      final capturados = List<Landmark>.generate(21, (index) {
        final x = switch (index) {
          0 => 0.5,
          4 => 0.62,
          8 => 0.65,
          12 => 0.66,
          16 => 0.64,
          20 => 0.63,
          _ => 0.5 + index * 0.002,
        };
        final y = switch (index) {
          0 => 0.5,
          4 => 0.38,
          8 => 0.28,
          12 => 0.22,
          16 => 0.18,
          20 => 0.16,
          _ => 0.5 + index * 0.001,
        };

        return Landmark(x: x, y: y, z: 0);
      });

      final resultado = ValidadorPosicion().validar(capturados, referencia);

      expect(resultado.correcto, isTrue);
    });

    test('rechaza una captura sin mano suficiente', () {
      final referencia = const PosicionMano(
        landmarksClave: [0, 4, 8, 12, 16, 20],
        anguloPulgar: 30,
        distanciaIndiceMedio: 0.32,
      );

      final capturados = List.generate(
        5,
        (index) => Landmark(x: 0.1 * index, y: 0.1 * index, z: 0),
      );

      final resultado = ValidadorPosicion().validar(capturados, referencia);

      expect(resultado.correcto, isFalse);
      expect(resultado.sugerencia, isNotNull);
    });
  });
}
