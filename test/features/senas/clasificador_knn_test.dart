import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/senas/models/landmark_model.dart';
import 'package:miapp/features/senas/services/clasificador_knn_service.dart';

void main() {
  final json = File(ClasificadorKnn.asset).readAsStringSync();
  final datos = jsonDecode(json) as Map<String, dynamic>;
  final muestras = datos['muestras'] as List;
  final knn = ClasificadorKnn.desdeJson(json);

  List<Landmark> puntos(Map m) => [
    for (var i = 0; i < 21; i++)
      Landmark(
        x: (m['p'][3 * i] as num).toDouble(),
        y: (m['p'][3 * i + 1] as num).toDouble(),
        z: (m['p'][3 * i + 2] as num).toDouble(),
      ),
  ];

  test('los rasgos de Dart coinciden con los de tool/generar_muestras.py', () {
    final m = muestras.first as Map;
    final r = ClasificadorKnn.rasgos(
      puntos(m),
      aspecto: (m['a'] as num).toDouble(),
    );
    final control = datos['control'] as List;
    for (var i = 0; i < r.length; i++) {
      expect(r[i], closeTo((control[i] as num).toDouble(), 1e-4), reason: '$i');
    }
  });

  test('el asset tiene muestras de cada letra kNN', () {
    final letras = {for (final m in muestras) m['s']};
    expect(letras, containsAll(ClasificadorKnn.letras));
    expect(letras, containsAll(ClasificadorKnn.numeros.map((n) => 'num-$n')));
  });

  test('una muestra grabada se acepta como su letra y no como otra', () {
    for (final letra in [
      ...ClasificadorKnn.letras,
      for (final n in ClasificadorKnn.numeros) 'num-$n',
    ]) {
      final m = muestras.firstWhere((m) => m['s'] == letra) as Map;
      final aspecto = (m['a'] as num).toDouble();
      final frontal = m['f'] as bool;
      final r = knn.puntuar(
        letra,
        puntos(m),
        aspecto: aspecto,
        frontal: frontal,
      );
      expect(r?.sena, letra, reason: letra);
      expect(r!.confianza, greaterThanOrEqualTo(0.8));
      final otra = letra.startsWith('num-')
          ? letra == 'num-1'
                ? 'num-2'
                : 'num-1'
          : ClasificadorKnn.letras.firstWhere((l) => l != letra);
      final ajena = knn.puntuar(
        otra,
        puntos(m),
        aspecto: aspecto,
        frontal: frontal,
      );
      expect(ajena == null || ajena.confianza < 0.75, isTrue, reason: letra);
    }
  });

  final b = muestras.firstWhere((m) => m['s'] == 'b') as Map;
  final aspectoB = (b['a'] as num).toDouble();

  test('una B con el pulgar estirado no cuenta', () {
    final p = puntos(b);
    expect(knn.puntuar('b', p, aspecto: aspectoB), isNotNull);
    // Pulgar recto: 2, 3 y 4 siguen la dirección muñeca → base del pulgar.
    final dx = p[1].x - p[0].x, dy = p[1].y - p[0].y, dz = p[1].z - p[0].z;
    final estirado = [
      for (var i = 0; i < 21; i++)
        i >= 2 && i <= 4
            ? Landmark(
                x: p[1].x + dx * 0.8 * (i - 1),
                y: p[1].y + dy * 0.8 * (i - 1),
                z: p[1].z + dz * 0.8 * (i - 1),
              )
            : p[i],
    ];
    final r = knn.puntuar('b', estirado, aspecto: aspectoB);
    expect(r == null || r.confianza < 0.75, isTrue, reason: 'no en verde');
  });

  test('girar la mano en 3D no cambia el resultado', () {
    final p = puntos(b);
    final w = p[0];
    for (final grados in [-35.0, 35.0]) {
      final t = grados * math.pi / 180, c = math.cos(t), s = math.sin(t);
      // Giro sobre el eje vertical, en unidades reales (x y z escaladas).
      final girada = [
        for (final l in p)
          () {
            final x = (l.x - w.x) * aspectoB, z = (l.z - w.z) * aspectoB;
            return Landmark(
              x: w.x + (x * c + z * s) / aspectoB,
              y: l.y,
              z: w.z + (-x * s + z * c) / aspectoB,
            );
          }(),
      ];
      expect(
        knn.puntuar('b', girada, aspecto: aspectoB)?.sena,
        'b',
        reason: '$grados°',
      );
    }
  });

  test('mano incompleta o cortada no puntúa', () {
    final m = muestras.first as Map;
    final p = puntos(m);
    expect(knn.puntuar(m['s'] as String, p.sublist(0, 10)), isNull);
    final cortada = [for (final l in p) Landmark(x: l.x + 2, y: l.y, z: 0)];
    expect(knn.puntuar(m['s'] as String, cortada), isNull);
  });
}
