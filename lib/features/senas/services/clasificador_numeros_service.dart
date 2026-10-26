import 'dart:math' as math;

import 'package:miapp/features/senas/models/landmark_model.dart';
import 'package:miapp/features/senas/models/reconocimiento_sena_model.dart';

/// Clasifica los números estáticos 1-9 de LSC a partir de los 21 landmarks.
///
/// Usa solo distancias y ángulos entre puntos, así que no depende de la
/// rotación, del tamaño de la mano ni de qué mano es. Los rangos de las rampas
/// son valores iniciales: deben calibrarse con muestras reales.
class ClasificadorNumeros {
  const ClasificadorNumeros();

  // Orden de dedos: pulgar, índice, medio, anular, meñique.
  // El 3 acepta dos variantes: índice-medio-anular (especificación pedida) y
  // pulgar-índice-medio (descripción de assets/data/senas.json).
  // shortcut: 0 y 10 pendientes; falta verificar fuentes LSC y el movimiento del 10.
  static const _esperados = <int, List<List<bool>>>{
    1: [
      [false, true, false, false, false],
    ],
    2: [
      [false, true, true, false, false],
    ],
    3: [
      [false, true, true, true, false],
      [true, true, true, false, false],
    ],
    4: [
      [false, true, true, true, true],
    ],
    5: [
      [true, true, true, true, true],
    ],
  };

  // 6-9: la punta del pulgar toca la punta de un dedo (1 índice … 4 meñique) y
  // los otros tres quedan extendidos (assets/data/senas.json y sus fotos).
  static const _contactos = {6: 4, 7: 3, 8: 2, 9: 1};

  /// Números que el clasificador sabe reconocer.
  static Iterable<int> get numerosSoportados => [
    ..._esperados.keys,
    ..._contactos.keys,
  ];

  // (mcp, pip, dip, tip) del índice al meñique.
  static const _dedos = [
    [5, 6, 7, 8],
    [9, 10, 11, 12],
    [13, 14, 15, 16],
    [17, 18, 19, 20],
  ];

  // Puntos de la palma y de los dedos recogidos donde descansa un pulgar doblado.
  static const _apoyosPulgar = [9, 10, 11, 13, 14, 15, 17, 18, 19];

  /// True si algún punto cae fuera de la imagen (mano cortada).
  static bool esParcial(List<Landmark> p, {double tolerancia = 0.01}) => p.any(
    (l) =>
        l.x < -tolerancia ||
        l.x > 1 + tolerancia ||
        l.y < -tolerancia ||
        l.y > 1 + tolerancia,
  );

  /// Puntaje de extensión (0 recogido, 1 extendido) de cada dedo.
  ///
  /// Solo usa distancias y ángulos, así que vale igual con la palma o el dorso
  /// hacia la cámara y con cualquier mano. [aspecto] es ancho/alto de la imagen
  /// ya girada; evita que x e y tengan unidades distintas.
  List<double> extensiones(List<Landmark> puntos, {double aspecto = 1}) {
    final p = escalar(puntos, aspecto);
    final palma = dist(p[0], p[9]);
    if (palma <= 1e-6) return List.filled(5, 0.0);

    final centro = (
      x: (p[0].x + p[5].x + p[9].x + p[13].x + p[17].x) / 5,
      y: (p[0].y + p[5].y + p[9].y + p[13].y + p[17].y) / 5,
      z: (p[0].z + p[5].z + p[9].z + p[13].z + p[17].z) / 5,
    );
    // Doblado, el pulgar toca la palma o algún dedo recogido; extendido, se aleja.
    final apoyo = [
      centro,
      for (final i in _apoyosPulgar) p[i],
    ].map((a) => dist(p[4], a)).reduce(math.min);
    final pulgar = rampa(apoyo / palma, 0.3, 0.6);

    return [
      pulgar,
      for (final d in _dedos)
        (rampa(_angulo(p[d[0]], p[d[1]], p[d[3]]), 100, 155) +
                rampa(dist(p[d[0]], p[d[3]]) / palma, 0.4, 0.7)) /
            2,
    ];
  }

  /// Cercanía (0 lejos, 1 tocando) de la punta del pulgar a la punta de cada
  /// dedo, del índice al meñique.
  List<double> contactos(List<Landmark> puntos, {double aspecto = 1}) {
    final p = escalar(puntos, aspecto);
    final palma = dist(p[0], p[9]);
    if (palma <= 1e-6) return List.filled(4, 0.0);
    return [
      for (final d in _dedos)
        1 - rampa(dist(p[4], p[d[3]]) / palma, 0.15, 0.35),
    ];
  }

  /// Mejor número para el fotograma, o null si no hay mano completa o ningún
  /// patrón coincide.
  ClasificacionSena? clasificar(List<Landmark> puntos, {double aspecto = 1}) {
    if (puntos.length < 21 || esParcial(puntos)) return null;
    return desdeExtensiones(
      extensiones(puntos, aspecto: aspecto),
      contactos: contactos(puntos, aspecto: aspecto),
    );
  }

  /// Exige que cada rasgo esté del lado correcto de 0.5; la confianza es la
  /// media de coincidencia, así un dedo dudoso no anula al resto. Sin
  /// [contactos] no se evalúan 6-9. Con [solo] se puntúa únicamente ese número,
  /// así una seña parecida (3 con el pulgar en el meñique frente a 6) no le
  /// gana a la que se practica.
  ClasificacionSena? desdeExtensiones(
    List<double> ext, {
    List<double> contactos = const [],
    int? solo,
  }) {
    final candidatos = [
      for (final e in _esperados.entries)
        for (final patron in e.value)
          (
            e.key,
            [for (var i = 0; i < 5; i++) patron[i] ? ext[i] : 1 - ext[i]],
          ),
      if (contactos.length == 4)
        for (final e in _contactos.entries)
          (
            e.key,
            [
              contactos[e.value - 1],
              for (var i = 1; i <= 4; i++)
                if (i != e.value) ext[i],
            ],
          ),
    ];
    ClasificacionSena? mejor;
    for (final (numero, coincidencias) in candidatos) {
      if (solo != null && numero != solo) continue;
      if (coincidencias.any((c) => c < 0.5)) continue;
      final confianza =
          coincidencias.reduce((a, b) => a + b) / coincidencias.length;
      if (mejor == null || confianza > mejor.confianza) {
        mejor = ClasificacionSena(numero, confianza);
      }
    }
    return mejor;
  }

  static List<({double x, double y, double z})> escalar(
    List<Landmark> puntos,
    double aspecto,
  ) => [for (final l in puntos) (x: l.x * aspecto, y: l.y, z: l.z * aspecto)];

  static double rampa(double v, double lo, double hi) =>
      ((v - lo) / (hi - lo)).clamp(0.0, 1.0);

  static double dist(
    ({double x, double y, double z}) a,
    ({double x, double y, double z}) b,
  ) => math.sqrt(
    math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2) + math.pow(a.z - b.z, 2),
  );

  /// Ángulo en grados en el vértice [b].
  static double _angulo(
    ({double x, double y, double z}) a,
    ({double x, double y, double z}) b,
    ({double x, double y, double z}) c,
  ) {
    final u = (x: a.x - b.x, y: a.y - b.y, z: a.z - b.z);
    final v = (x: c.x - b.x, y: c.y - b.y, z: c.z - b.z);
    final m = dist(a, b) * dist(c, b);
    if (m == 0) return 0;
    final cos = ((u.x * v.x + u.y * v.y + u.z * v.z) / m).clamp(-1.0, 1.0);
    return math.acos(cos) * 180 / math.pi;
  }
}
