import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/core/utils/json_utils.dart';
import 'package:miapp/features/senas/services/senas_locales_service.dart';

const _json = '''
[
  {
    "id": "sena-001",
    "nombre": "A",
    "categoria": "Alfabeto",
    "descripcion": "Puño cerrado con el pulgar apoyado al costado del índice.",
    "posicionReferencia": {
      "landmarksClave": [4, 8, 12, 16, 20],
      "anguloPulgar": 15.5,
      "distanciaIndiceMedio": 2.1
    },
    "estadoAprendizaje": { "tipo": "no_iniciada" }
  },
  {
    "id": "sena-002",
    "nombre": "Hola",
    "categoria": "Saludos",
    "descripcion": "Mano abierta cerca de la sien.",
    "posicionReferencia": {
      "landmarksClave": [0, 4, 8, 12, 16, 20],
      "anguloPulgar": 40.0,
      "distanciaIndiceMedio": 3.4
    },
    "estadoAprendizaje": {
      "tipo": "dominada",
      "fechaDominada": "2026-08-05T14:30:00Z",
      "precision": 0.93
    }
  }
]
''';

void main() {
  test('lee la lista completa del archivo', () async {
    final repo = SenasLocales(lector: (_) async => _json);
    expect((await repo.obtenerTodas()).length, 2);
  });

  test('busca por id y devuelve null cuando no está', () async {
    final repo = SenasLocales(lector: (_) async => _json);

    expect((await repo.obtenerPorId('sena-001'))?.nombre, 'A');
    expect(await repo.obtenerPorId('no-existe'), isNull);
  });

  test(
    'obtenerPendientes incluye las no iniciadas y excluye las dominadas',
    () async {
      final repo = SenasLocales(lector: (_) async => _json);
      final pendientes = await repo.obtenerPendientes();

      expect(pendientes.map((s) => s.id), contains('sena-001'));
      expect(pendientes.map((s) => s.id), isNot(contains('sena-002')));
    },
  );

  test('un archivo que no es una lista se rechaza', () async {
    final repo = SenasLocales(lector: (_) async => '{"a": 1}');
    expect(repo.obtenerTodas(), throwsA(isA<CampoInvalido>()));
  });

  test(
    'el asset declarado en pubspec existe y el modelo lo entiende',
    () async {
      // Esta SÍ toca el bundle: es la única que caza "olvidé el pubspec".
      TestWidgetsFlutterBinding.ensureInitialized();

      final repo = SenasLocales(lector: rootBundle.loadString);
      expect((await repo.obtenerTodas()).length, greaterThanOrEqualTo(3));
    },
  );
}
