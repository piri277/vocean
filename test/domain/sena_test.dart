import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/core/json.dart';
import 'package:miapp/features/senas/domain/estado_aprendizaje.dart';
import 'package:miapp/features/senas/domain/posicion_mano.dart';
import 'package:miapp/features/senas/domain/sena.dart';

Sena ejemplo({
  EstadoAprendizaje? estado,
  List<int>? landmarks,
  String? videoReferencia,
}) => Sena(
  id: 'sena-001',
  nombre: 'A',
  categoria: 'Alfabeto',
  descripcion: 'Puño cerrado con el pulgar apoyado al costado del índice.',
  posicionReferencia: PosicionMano(
    landmarksClave: landmarks ?? const [4, 8, 12, 16, 20],
    anguloPulgar: 15.5,
    distanciaIndiceMedio: 2.1,
  ),
  estadoAprendizaje: estado ?? const NoIniciada(),
  videoReferencia: videoReferencia,
);

void main() {
  group('serialización', () {
    test('una seña sobrevive la ida y vuelta a JSON sin perder nada', () {
      final original = ejemplo(
        estado: Dominada(DateTime.utc(2026, 8, 5, 14, 30), 0.93),
        videoReferencia: 'https://ejemplo.co/videos/letra_a.mp4',
      );

      // Pasa por TEXTO, no solo por Map: así también se prueba que las
      // fechas y las listas sobreviven a jsonEncode.
      final texto = jsonEncode(original.toJson());
      final vuelta = Sena.fromJson(jsonDecode(texto) as Map<String, dynamic>);

      expect(vuelta, equals(original));
    });

    test('una seña sin video se lee con videoReferencia en null', () {
      final json = ejemplo().toJson()..remove('videoReferencia');
      expect(Sena.fromJson(json).videoReferencia, isNull);
    });

    test('una seña sin nombre dice QUÉ campo falló, no solo que falló', () {
      final json = ejemplo().toJson()..remove('nombre');

      expect(
        () => Sena.fromJson(json),
        throwsA(isA<CampoInvalido>().having((e) => e.campo, 'campo', 'nombre')),
      );
    });

    test('landmarksClave con un elemento que no es entero se rechaza', () {
      final json = ejemplo().toJson();
      (json['posicionReferencia'] as Map<String, dynamic>)['landmarksClave'] = [
        4,
        'ocho',
        12,
      ];

      expect(() => Sena.fromJson(json), throwsA(isA<CampoInvalido>()));
    });

    test('la fecha de dominada se conserva en UTC y no se corre de hora', () {
      final json = ejemplo(
        estado: Dominada(DateTime.utc(2026, 8, 5, 14, 30), 0.93),
      ).toJson();

      final estado = json['estadoAprendizaje'] as Map<String, dynamic>;
      expect(estado['fechaDominada'], '2026-08-05T14:30:00.000Z');
    });
  });

  group('igualdad', () {
    test('dos señas con los mismos datos son iguales', () {
      expect(ejemplo(), equals(ejemplo()));
    });

    test('dos señas con los mismos datos comparten hashCode', () {
      // Sin esto, meterlas en un Set daría dos elementos donde debería haber uno.
      expect(ejemplo().hashCode, equals(ejemplo().hashCode));
      expect({ejemplo(), ejemplo()}.length, 1);
    });

    test('dos señas con distintos landmarksClave NO son iguales', () {
      expect(
        ejemplo(landmarks: const [4, 8]),
        isNot(equals(ejemplo(landmarks: const [4, 8, 12]))),
      );
    });

    test('copyWith cambia solo lo que se le pasa', () {
      final original = ejemplo();
      final copia = original.copyWith(nombre: 'A modificada');

      expect(copia.nombre, 'A modificada');
      expect(copia.id, original.id);
      expect(copia.categoria, original.categoria);
    });
  });

  group('reglas de negocio', () {
    test('una seña en práctica requiere atención', () {
      final sena = ejemplo(estado: EnPractica(3, DateTime.utc(2026, 8, 10)));
      expect(sena.requierePractica, isTrue);
    });

    test('una seña dominada hace 20 días recomienda repaso', () {
      final sena = ejemplo(
        estado: Dominada(DateTime.utc(2026, 7, 26), 0.9), // hace 20 días
      );
      final ahora = DateTime.utc(2026, 8, 15);
      expect(sena.debeRecomendarRepaso(ahora), isTrue);
    });

    test('una seña dominada hace 3 días NO recomienda repaso todavía', () {
      final sena = ejemplo(
        estado: Dominada(DateTime.utc(2026, 8, 12), 0.9), // hace 3 días
      );
      final ahora = DateTime.utc(2026, 8, 15);
      expect(sena.debeRecomendarRepaso(ahora), isFalse);
    });
  });
}
