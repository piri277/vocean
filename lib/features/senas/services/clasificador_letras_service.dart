import 'dart:math' as math;

import 'package:miapp/features/senas/models/landmark_model.dart';
import 'package:miapp/features/senas/models/reconocimiento_numero_model.dart';
import 'package:miapp/features/senas/services/clasificador_numeros_service.dart';

typedef _Rasgos = ({
  List<double> ext,
  List<double> cont,
  double separacion,
  double cruce,
  double juntos,
  double lateral,
  double abajo,
  double pulgarEnMedio,
});

/// Puntúa una letra estática de LSC concreta a partir de los 21 landmarks.
///
/// Solo se usa al practicar una seña: varias letras comparten forma con
/// números u otras letras (V y 2, F y 9, W y 6), así que no se elige la mejor
/// entre todas. Las definiciones salen de assets/data/senas.json y los rangos
/// son valores iniciales: deben calibrarse con muestras reales.
// shortcut: g, h, j, s, z y ñ pendientes; j y z llevan movimiento.
class ClasificadorLetras {
  const ClasificadorLetras();

  static const _numeros = ClasificadorNumeros();

  // Cada letra da puntajes 0-1 que deben superar 0.5; ext: pulgar a meñique,
  // cont: pulgar tocando índice a meñique.
  static final Map<String, List<double> Function(_Rasgos)> _condiciones = {
    // Puño con el pulgar al costado del índice.
    'a': (r) => [..._doblados(r), 1 - _r(r.lateral, 0, 0.15)],
    // Cuatro dedos rectos y juntos, pulgar sobre la palma.
    'b': (r) => [1 - r.ext[0], ...r.ext.sublist(1), r.juntos],
    // Dedos curvos sin cerrar el círculo con el pulgar.
    'c': (r) => [
      r.ext[0],
      for (var i = 1; i <= 4; i++) _entre(r.ext[i], 0.2, 0.8),
      1 - r.cont[0],
    ],
    // Índice arriba; el medio toca la punta del pulgar.
    'd': (r) => [r.ext[1], r.cont[1], 1 - r.ext[3], 1 - r.ext[4]],
    // Dedos doblados con las puntas sobre el pulgar.
    'e': (r) => [..._doblados(r), math.max(r.cont[0], r.cont[1])],
    // Pulgar e índice en círculo, los otros tres arriba.
    'f': (r) => [r.cont[0], r.ext[2], r.ext[3], r.ext[4]],
    'i': (r) => [
      1 - r.ext[0],
      1 - r.ext[1],
      1 - r.ext[2],
      1 - r.ext[3],
      r.ext[4],
    ],
    // V hacia arriba con el pulgar en la base del medio.
    'k': (r) => [..._ve(r), r.pulgarEnMedio, 1 - r.abajo],
    'l': (r) => [r.ext[0], r.ext[1], 1 - r.ext[2], 1 - r.ext[3], 1 - r.ext[4]],
    // Puño con el pulgar asomando entre anular y meñique.
    'm': (r) => [..._doblados(r), _cerca(r.lateral, 0.83)],
    // Puño con el pulgar asomando entre medio y anular.
    'n': (r) => [..._doblados(r), _cerca(r.lateral, 0.5)],
    'o': (r) => [r.cont[0], r.cont[1], r.cont[2]],
    // K apuntando hacia abajo.
    'p': (r) => [..._ve(r), r.pulgarEnMedio, r.abajo],
    // G apuntando hacia abajo: índice y pulgar extendidos.
    'q': (r) => [
      r.ext[0],
      r.ext[1],
      1 - r.ext[2],
      1 - r.ext[3],
      1 - r.ext[4],
      r.abajo,
    ],
    'r': (r) => [..._ve(r), r.cruce],
    // Puño con el pulgar asomando entre índice y medio.
    't': (r) => [..._doblados(r), _cerca(r.lateral, 0.17)],
    'u': (r) => [1 - r.ext[0], ..._ve(r), 1 - r.separacion, 1 - r.cruce],
    'v': (r) => [1 - r.ext[0], ..._ve(r), r.separacion, 1 - r.cruce],
    'w': (r) => [1 - r.ext[0], r.ext[1], r.ext[2], r.ext[3], 1 - r.ext[4]],
    // Puño con el índice en gancho.
    'x': (r) => [
      _entre(r.ext[1], 0.1, 0.55),
      1 - r.ext[2],
      1 - r.ext[3],
      1 - r.ext[4],
    ],
    'y': (r) => [r.ext[0], 1 - r.ext[1], 1 - r.ext[2], 1 - r.ext[3], r.ext[4]],
  };

  /// Letras (minúsculas) que se pueden practicar.
  static Iterable<String> get letrasSoportadas => _condiciones.keys;

  /// Confianza de que la mano forma [letra], o null si no la forma o la mano
  /// está incompleta.
  ClasificacionNumero? puntuar(
    String letra,
    List<Landmark> puntos, {
    double aspecto = 1,
  }) {
    final condicion = _condiciones[letra];
    if (condicion == null ||
        puntos.length < 21 ||
        ClasificadorNumeros.esParcial(puntos)) {
      return null;
    }
    final puntajes = condicion(_rasgos(puntos, aspecto));
    if (puntajes.any((c) => c < 0.5)) return null;
    return ClasificacionNumero(
      letra,
      puntajes.reduce((a, b) => a + b) / puntajes.length,
    );
  }

  _Rasgos _rasgos(List<Landmark> puntos, double aspecto) {
    final p = ClasificadorNumeros.escalar(puntos, aspecto);
    final palma = math.max(ClasificadorNumeros.dist(p[0], p[9]), 1e-6);
    double d(int a, int b) => ClasificadorNumeros.dist(p[a], p[b]) / palma;
    double punto(int a, int b, ({double x, double y, double z}) eje) =>
        (p[a].x - p[b].x) * eje.x +
        (p[a].y - p[b].y) * eje.y +
        (p[a].z - p[b].z) * eje.z;

    // Eje de los nudillos (índice→meñique): 0 en el índice, 1 en el meñique.
    final nudillos = (
      x: p[17].x - p[5].x,
      y: p[17].y - p[5].y,
      z: p[17].z - p[5].z,
    );
    final largo2 = math.max(punto(17, 5, nudillos), 1e-9);
    // Hacia el lado del índice; con los dedos cruzados la punta del índice
    // queda del lado del medio.
    final ladoIndice = (
      x: p[5].x - p[9].x,
      y: p[5].y - p[9].y,
      z: p[5].z - p[9].z,
    );
    final ladoLargo = math.max(ClasificadorNumeros.dist(p[5], p[9]), 1e-6);

    return (
      ext: _numeros.extensiones(puntos, aspecto: aspecto),
      cont: _numeros.contactos(puntos, aspecto: aspecto),
      separacion: _r(d(8, 12), 0.25, 0.45),
      cruce: _r(-punto(8, 12, ladoIndice) / ladoLargo / palma, 0, 0.1),
      juntos: 1 - _r((d(8, 12) + d(12, 16) + d(16, 20)) / 3, 0.25, 0.4),
      lateral: punto(4, 5, nudillos) / largo2,
      // En la imagen y crece hacia abajo.
      abajo: _r((p[9].y - p[0].y) / palma, 0.2, 0.6),
      pulgarEnMedio: 1 - _r(math.min(d(4, 9), d(4, 10)), 0.2, 0.4),
    );
  }

  static List<double> _doblados(_Rasgos r) => [
    for (var i = 1; i <= 4; i++) 1 - r.ext[i],
  ];

  // Índice y medio extendidos, anular y meñique recogidos.
  static List<double> _ve(_Rasgos r) => [
    r.ext[1],
    r.ext[2],
    1 - r.ext[3],
    1 - r.ext[4],
  ];

  static double _r(double v, double lo, double hi) =>
      ClasificadorNumeros.rampa(v, lo, hi);

  // 1 dentro de [lo, hi]; vale 0.5 a 0.05 fuera del rango.
  static double _entre(double v, double lo, double hi) =>
      1 - _r(math.max(lo - v, v - hi), 0, 0.1);

  // 1 cerca de [c]; vale 0.5 a 0.14 de distancia.
  static double _cerca(double v, double c) => 1 - _r((v - c).abs(), 0.08, 0.2);
}
