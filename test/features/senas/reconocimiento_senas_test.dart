import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/senas/models/landmark_model.dart';
import 'package:miapp/features/senas/models/reconocimiento_sena_model.dart';
import 'package:miapp/features/senas/services/clasificador_letras_service.dart';
import 'package:miapp/features/senas/services/clasificador_numeros_service.dart';
import 'package:miapp/features/senas/services/estabilizador_reconocimiento_service.dart';

// Mano sintética con los dedos hacia arriba. Orden de `ext`: pulgar, índice,
// medio, anular, meñique. `dorso`: el dorso mira a la cámara, así que la mano
// se ve espejada y los dedos recogidos se ocultan tras los nudillos (z > 0).
// `apoyoPulgar`: dónde descansa la punta del pulgar recogido.
// `toca`: dedo (1 índice … 4 meñique) medio doblado cuya punta toca la del
// pulgar, como en 6-9.
const mcp = [(-0.3, -0.95), (0.0, -1.0), (0.28, -0.95), (0.55, -0.85)];

List<Landmark> mano(
  List<bool> ext, {
  double escala = 0.2,
  double giro = 0,
  double ruido = 0,
  double cx = 0.5,
  double cy = 0.65,
  bool dorso = false,
  bool conZ = true,
  (double, double) apoyoPulgar = (-0.1, -0.7),
  int? toca,
}) {
  if (toca != null) {
    final (x, y) = mcp[toca - 1];
    apoyoPulgar = (x - 0.25, y - 0.5);
  }
  final rnd = math.Random(7);
  final pts = <(double, double, double)>[(0, 0, 0), (-0.3, -0.2, 0)];
  pts.addAll(
    ext[0]
        ? [(-0.55, -0.35, 0), (-0.85, -0.45, 0), (-1.15, -0.55, 0)]
        : [
            (-0.45, -0.4, 0),
            (
              (-0.45 + apoyoPulgar.$1) / 2,
              (-0.4 + apoyoPulgar.$2) / 2 - 0.1,
              0,
            ),
            (apoyoPulgar.$1, apoyoPulgar.$2, dorso ? 0.1 : 0),
          ],
  );
  for (var i = 0; i < 4; i++) {
    final (x, y) = mcp[i];
    pts.add((x, y, 0));
    pts.addAll(
      toca == i + 1
          ? [(x, y - 0.4, 0), (x - 0.15, y - 0.55, 0), (x - 0.25, y - 0.5, 0)]
          : ext[i + 1]
          ? [(x, y - 0.45, 0), (x, y - 0.75, 0), (x, y - 1.0, 0)]
          : dorso
          ? [(x, y - 0.4, 0), (x, y - 0.4, 0.2), (x, y - 0.3, 0.2)]
          : [(x, y - 0.35, 0), (x, y - 0.25, 0), (x, y + 0.05, 0)],
    );
  }
  final c = math.cos(giro), s = math.sin(giro);
  double n() => (rnd.nextDouble() - 0.5) * 2 * ruido;
  Landmark punto(double x, double y, double z) => Landmark(
    x: cx + escala * (x * c - y * s) + n(),
    y: cy + escala * (x * s + y * c) + n(),
    z: conZ ? escala * z : 0,
  );
  return [for (final (x, y, z) in pts) punto(dorso ? -x : x, y, z)];
}

const numeros = {
  1: [false, true, false, false, false],
  2: [false, true, true, false, false],
  3: [false, true, true, true, false],
  4: [false, true, true, true, true],
  5: [true, true, true, true, true],
};

void main() {
  const clasificador = ClasificadorNumeros();

  group('clasificador', () {
    for (final e in numeros.entries) {
      test('reconoce el ${e.key}', () {
        final r = clasificador.clasificar(mano(e.value));
        expect(r?.sena, e.key);
        expect(r!.confianza, greaterThan(0.75));
      });
    }

    test('invariante a rotación, tamaño y ruido leve', () {
      for (final e in numeros.entries) {
        for (final giro in [-0.7, 0.0, 0.5, math.pi / 2]) {
          for (final escala in [0.1, 0.2]) {
            final r = clasificador.clasificar(
              mano(e.value, giro: giro, escala: escala, ruido: 0.002),
            );
            expect(r?.sena, e.key, reason: '${e.key} giro=$giro esc=$escala');
          }
        }
      }
    });

    test('con el dorso hacia la cámara, con y sin z', () {
      for (final e in numeros.entries) {
        for (final conZ in [true, false]) {
          for (final giro in [-0.5, 0.0, 0.6]) {
            final r = clasificador.clasificar(
              mano(e.value, dorso: true, conZ: conZ, giro: giro, ruido: 0.002),
            );
            expect(r?.sena, e.key, reason: '${e.key} z=$conZ giro=$giro');
            expect(r!.confianza, greaterThan(0.75));
          }
        }
      }
    });

    test('3 con el pulgar sujetando el meñique', () {
      for (final dorso in [false, true]) {
        final r = clasificador.clasificar(
          mano(numeros[3]!, apoyoPulgar: (0.5, -1.15), dorso: dorso),
        );
        expect(r?.sena, 3, reason: 'dorso=$dorso');
      }
    });

    test('3 en variante pulgar-índice-medio', () {
      final r = clasificador.clasificar(
        mano([true, true, true, false, false], apoyoPulgar: (0.4, -0.9)),
      );
      expect(r?.sena, 3);
    });

    for (final (numero, dedo) in [(6, 4), (7, 3), (8, 2), (9, 1)]) {
      test('reconoce el $numero (pulgar toca el dedo $dedo)', () {
        final ext = [false, for (var i = 1; i <= 4; i++) i != dedo];
        for (final dorso in [false, true]) {
          for (final giro in [-0.5, 0.0, 0.6]) {
            final r = clasificador.clasificar(
              mano(ext, toca: dedo, dorso: dorso, giro: giro, ruido: 0.002),
            );
            expect(r?.sena, numero, reason: 'dorso=$dorso giro=$giro');
            expect(r!.confianza, greaterThan(0.75));
          }
        }
      });
    }

    test('con objetivo solo puntúa ese número', () {
      const ext = [0.1, 0.9, 0.9, 0.9, 0.1];
      const cont = [0.0, 0.0, 0.0, 0.9];
      expect(
        clasificador.desdeExtensiones(ext, contactos: cont, solo: 6)?.sena,
        6,
      );
      expect(
        clasificador.desdeExtensiones(ext, contactos: cont, solo: 3)?.sena,
        3,
      );
      expect(
        clasificador.desdeExtensiones(ext, contactos: cont, solo: 2),
        isNull,
      );
    });

    test('0: índice, medio y anular tocan el pulgar', () {
      const ext = [0.3, 0.4, 0.4, 0.4, 0.4];
      const cont = [0.9, 0.9, 0.8, 0.3];
      expect(clasificador.desdeExtensiones(ext, contactos: cont)?.sena, 0);
      expect(
        clasificador.desdeExtensiones(ext, contactos: cont, solo: 0)?.sena,
        0,
      );
      expect(
        clasificador.desdeExtensiones(
          ext,
          contactos: const [0.9, 0.2, 0.2, 0.2],
        ),
        isNull,
      );
    });

    test('sin tres dedos extendidos el contacto no basta', () {
      expect(
        clasificador
            .desdeExtensiones(
              [0.1, 0.1, 0.9, 0.9, 0.1],
              contactos: const [0.0, 0.0, 0.0, 0.9],
            )
            ?.sena,
        isNot(6),
      );
    });

    test('un dedo dudoso no anula el resto', () {
      final r = clasificador.desdeExtensiones([0.1, 0.9, 0.9, 0.55, 0.1]);
      expect(r?.sena, 3);
      expect(r!.confianza, greaterThan(0.75));
    });

    test('un dedo del lado equivocado descarta el número', () {
      expect(
        clasificador.desdeExtensiones([0.1, 0.9, 0.45, 0.1, 0.1])?.sena,
        1,
      );
      expect(clasificador.desdeExtensiones([0.6, 0.9, 0.1, 0.1, 0.1]), isNull);
    });

    test('puño cerrado no es ningún número', () {
      final r = clasificador.clasificar(
        mano([false, false, false, false, false]),
      );
      expect(r == null || r.confianza < 0.75, isTrue);
    });

    test('mano cortada por el borde no se clasifica', () {
      expect(clasificador.clasificar(mano(numeros[5]!, cx: 0.95)), isNull);
    });

    test('menos de 21 puntos no se clasifica', () {
      expect(clasificador.clasificar(mano(numeros[1]!).sublist(0, 10)), isNull);
    });
  });

  group('letras', () {
    const letras = ClasificadorLetras();
    const puno = [false, false, false, false, false];

    test('soporta las letras pedidas', () {
      expect(ClasificadorLetras.letrasSoportadas.toSet(), {
        ...'abciloprvwy'.split(''),
      });
    });

    test('reconoce l, y, i, w y b', () {
      final casos = {
        'l': mano([true, true, false, false, false]),
        'y': mano([true, false, false, false, true]),
        'i': mano([false, false, false, false, true]),
        'w': mano([false, true, true, true, false], apoyoPulgar: (0.5, -1.15)),
        'b': mano([false, true, true, true, true]),
      };
      for (final e in casos.entries) {
        expect(letras.puntuar(e.key, e.value)?.sena, e.key, reason: e.key);
      }
    });

    test('dedos juntos no son V ni R', () {
      final m = mano([false, true, true, false, false]);
      expect(letras.puntuar('v', m), isNull);
      expect(letras.puntuar('r', m), isNull);
    });

    test('A solo con el pulgar al costado del índice', () {
      expect(
        letras.puntuar('a', mano(puno, apoyoPulgar: (-0.45, -1.0))),
        isNotNull,
      );
      expect(
        letras.puntuar('a', mano(puno, apoyoPulgar: (0.14, -0.9))),
        isNull,
      );
    });

    test('P solo con la mano hacia abajo', () {
      const ve = [false, true, true, false, false];
      final arriba = mano(ve, apoyoPulgar: (0.0, -1.3));
      final abajo = mano(ve, apoyoPulgar: (0.0, -1.3), giro: math.pi, cy: 0.3);
      expect(abajo.every((l) => l.y >= 0 && l.y <= 1), isTrue);
      expect(letras.puntuar('p', abajo)?.sena, 'p');
      expect(letras.puntuar('p', arriba), isNull);
    });

    test('mano incompleta no puntúa', () {
      expect(letras.puntuar('l', mano(numeros[5]!, cx: 0.95)), isNull);
    });
  });

  group('estabilizador', () {
    const uno = ClasificacionSena(1, 0.9);
    const dos = ClasificacionSena(2, 0.9);
    late EstabilizadorReconocimiento est;
    setUp(() => est = EstabilizadorReconocimiento());

    ResultadoReconocimiento alimentar(int n, ClasificacionSena? c) {
      late ResultadoReconocimiento r;
      for (var i = 0; i < n; i++) {
        r = est.actualizar(hayMano: c != null, clasificacion: c);
      }
      return r;
    }

    test('no confirma antes de suficientes frames', () {
      expect(alimentar(5, uno).confirmada, isFalse);
      expect(alimentar(1, uno).confirmada, isTrue);
    });

    test('un frame suelto no cambia el número confirmado', () {
      alimentar(8, uno);
      final r = est.actualizar(hayMano: true, clasificacion: dos);
      expect(r.sena, 1);
      expect(r.confirmada, isTrue);
    });

    test('cambio de número requiere frames consistentes', () {
      alimentar(10, uno);
      var r = alimentar(3, dos);
      expect(r.sena == 2 && r.confirmada, isFalse);
      r = alimentar(4, dos);
      expect(r.sena, 2);
      expect(r.confirmada, isTrue);
    });

    test('confianza bajo el umbral no confirma, pero queda en analizando', () {
      final r = alimentar(10, const ClasificacionSena(1, 0.6));
      expect(r.estado, EstadoReconocimiento.analizando);
      expect(r.sena, 1);
    });

    test('sin mano termina en sinMano', () {
      alimentar(8, uno);
      expect(alimentar(10, null).estado, EstadoReconocimiento.sinMano);
    });

    test('mano parcial', () {
      final r = est.actualizar(hayMano: true, parcial: true);
      expect(r.estado, EstadoReconocimiento.manoParcial);
    });
  });
}
