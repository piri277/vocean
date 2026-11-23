import 'dart:convert';
import 'dart:math' as math;

import 'package:miapp/features/senas/models/landmark_model.dart';
import 'package:miapp/features/senas/models/reconocimiento_sena_model.dart';
import 'package:miapp/features/senas/services/clasificador_numeros_service.dart';

typedef _Punto = ({double x, double y, double z});
typedef _Plantilla = ({String sena, List<double> rasgos});

/// Verifica letras comparando la mano con muestras reales grabadas
/// (assets/data/muestras_senas.json, generado por tool/generar_muestras.py)
/// por k vecinos más cercanos.
///
/// Los rasgos (ángulos 3D de cada articulación y distancias entre puntas,
/// relativas a la palma) no cambian al girar la mano en ningún eje, ni con su
/// tamaño ni con qué mano es. Cada rasgo se divide por su variación dentro de
/// una misma letra, así un dedo fuera de lugar pesa mucho más que el temblor.
/// Cada letra tiene su umbral, medido con sus propias muestras: las que se
/// graban muy parejas (T, R, U, V…) son más estrictas.
// shortcut: muestras de una sola persona; grabar más manos para generalizar.
class ClasificadorKnn {
  ClasificadorKnn._(this._escala, this._umbrales, this._plantillas);

  /// Lee el JSON del asset: `escala`, `umbrales` y `muestras`
  /// (`[{"s": letra, "f": frontal, "a": aspecto, "p": [x,y,z ×21]}]`).
  factory ClasificadorKnn.desdeJson(String json) {
    final datos = jsonDecode(json) as Map<String, dynamic>;
    final escala = [
      for (final e in datos['escala'] as List) (e as num).toDouble(),
    ];
    final umbrales = {
      for (final MapEntry(:key, :value)
          in (datos['umbrales'] as Map<String, dynamic>).entries)
        key: (
          distancia: ((value as List)[0] as num).toDouble(),
          dedo: (value[1] as num).toDouble(),
        ),
    };
    return ClasificadorKnn._(escala, umbrales, [
      for (final m in datos['muestras'] as List)
        (
          sena: m['s'] as String,
          rasgos: _normalizar(
            rasgos(
              _puntos(m['p'] as List),
              aspecto: (m['a'] as num).toDouble(),
            ),
            escala,
          ),
        ),
    ]);
  }

  static const asset = 'assets/data/muestras_senas.json';

  /// Letras que se practican con este clasificador: todas las que tienen
  /// muestras salvo la j, que lleva movimiento.
  static const letras = {
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'k', 'l', 'm', //
    'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y',
  };

  /// Números con muestras; en el asset se llaman `num-0` … `num-9`.
  static const numeros = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

  static const _k = 5;
  static const _votosMinimos = 3;

  /// Fuera del umbral pero dentro de este múltiplo, la mano está cerca: la
  /// confianza baja de 0.75 y la UI la muestra en naranja, no en verde.
  static const _margenCerca = 1.6;
  static const confianzaCerca = 0.6;

  final List<double> _escala;
  final Map<String, ({double distancia, double dedo})> _umbrales;
  final List<_Plantilla> _plantillas;

  /// Confianza de que la mano forma [letra], o null si no se parece.
  ///
  /// De 0.8 (3 de 5 vecinos) a 1.0 (5 de 5) si la forma; [confianzaCerca] si
  /// solo se le acerca. Compara con las muestras de ambas cámaras: los rasgos
  /// son ángulos y distancias, iguales en espejo, y así las muestras de otras
  /// manos grabadas con la trasera también sirven en la frontal.
  ClasificacionSena? puntuar(
    String letra,
    List<Landmark> puntos, {
    double aspecto = 1,
  }) {
    final umbral = _umbrales[letra];
    if (umbral == null ||
        puntos.length < 21 ||
        ClasificadorNumeros.esParcial(puntos)) {
      return null;
    }
    // Letras y números votan aparte: V y 2, W y 6, O y 0 son la misma mano
    // y se robarían los votos.
    final numero = letra.startsWith('num-');
    final tipo = _plantillas.where((p) => p.sena.startsWith('num-') == numero);
    final r = _normalizar(rasgos(puntos, aspecto: aspecto), _escala);
    final cercanas = [for (final p in tipo) (p: p, d: _dist(r, p.rasgos))]
      ..sort((a, b) => a.d.compareTo(b.d));
    final votos = cercanas.take(_k).where((c) => c.p.sena == letra).length;
    final propia = cercanas.where((c) => c.p.sena == letra).firstOrNull;
    if (propia == null) return null;
    final dedo = _peorDedo(r, propia.p.rasgos);
    if (votos >= _votosMinimos &&
        propia.d <= umbral.distancia &&
        dedo <= umbral.dedo) {
      return ClasificacionSena(letra, 0.5 + votos / (2 * _k));
    }
    if (propia.d <= umbral.distancia * _margenCerca &&
        dedo <= umbral.dedo * _margenCerca) {
      return ClasificacionSena(letra, confianzaCerca);
    }
    return null;
  }

  // (base, articulación, siguiente) de cada dedo, del pulgar al meñique.
  static const _cadenas = [
    [0, 1, 2, 3, 4],
    [0, 5, 6, 7, 8],
    [0, 9, 10, 11, 12],
    [0, 13, 14, 15, 16],
    [0, 17, 18, 19, 20],
  ];
  static const _puntas = [4, 8, 12, 16, 20];

  // Nudillos y falanges donde se apoya el pulgar en k, m, n, s y t.
  static const _apoyosPulgar = [5, 6, 9, 10, 13, 14];

  static List<Landmark> _puntos(List p) => [
    for (var i = 0; i < 21; i++)
      Landmark(
        x: (p[3 * i] as num).toDouble(),
        y: (p[3 * i + 1] as num).toDouble(),
        z: (p[3 * i + 2] as num).toDouble(),
      ),
  ];

  /// Vector de rasgos de una mano (21 puntos), sin normalizar. Los 15 primeros
  /// son los ángulos de cada dedo (3 por dedo, del pulgar al meñique). Debe
  /// coincidir con `rasgos` de tool/generar_muestras.py.
  static List<double> rasgos(List<Landmark> puntos, {double aspecto = 1}) {
    final p = [
      for (final l in puntos) (x: l.x * aspecto, y: l.y, z: l.z * aspecto),
    ];
    final palma = math.max(ClasificadorNumeros.dist(p[0], p[9]), 1e-6);
    double d(int a, int b) => ClasificadorNumeros.dist(p[a], p[b]) / palma;
    return [
      for (final c in _cadenas)
        for (var j = 1; j <= 3; j++) _angulo(p[c[j - 1]], p[c[j]], p[c[j + 1]]),
      for (var i = 0; i < 5; i++)
        for (var j = i + 1; j < 5; j++) d(_puntas[i], _puntas[j]),
      for (final t in _puntas) d(t, 0),
      for (final a in _apoyosPulgar) d(4, a),
    ];
  }

  static List<double> _normalizar(List<double> r, List<double> escala) => [
    for (var k = 0; k < r.length; k++) r[k] / escala[k],
  ];

  // Desvío medio del dedo que más se aleja de la muestra (sus 3 ángulos).
  static double _peorDedo(List<double> a, List<double> b) => [
    for (var f = 0; f < 5; f++)
      math.sqrt(
        [for (var q = 3 * f; q < 3 * f + 3; q++) (a[q] - b[q]) * (a[q] - b[q])]
                .reduce((x, y) => x + y) /
            3,
      ),
  ].reduce(math.max);

  // Ángulo 3D en [b] normalizado a 0-1 (0° a 180°).
  static double _angulo(_Punto a, _Punto b, _Punto c) {
    final ux = a.x - b.x, uy = a.y - b.y, uz = a.z - b.z;
    final vx = c.x - b.x, vy = c.y - b.y, vz = c.z - b.z;
    final m = ClasificadorNumeros.dist(a, b) * ClasificadorNumeros.dist(c, b);
    if (m == 0) return 0;
    return math.acos(((ux * vx + uy * vy + uz * vz) / m).clamp(-1.0, 1.0)) /
        math.pi;
  }

  // Distancia media por rasgo (euclídea / √n), en desviaciones típicas.
  static double _dist(List<double> a, List<double> b) {
    var s = 0.0;
    for (var i = 0; i < a.length; i++) {
      s += (a[i] - b[i]) * (a[i] - b[i]);
    }
    return math.sqrt(s / a.length);
  }
}
