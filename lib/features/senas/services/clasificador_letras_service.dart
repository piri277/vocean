import 'dart:math' as math;

import 'package:miapp/features/senas/models/landmark_model.dart';
import 'package:miapp/features/senas/models/reconocimiento_sena_model.dart';
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
/// números (V y 2, W y 6), así que no se elige la mejor
/// entre todas. Las definiciones salen de assets/data/senas.json y los rangos
/// son valores iniciales: deben calibrarse con muestras reales.
// shortcut: las letras con muestras van por ClasificadorKnn y estas reglas ya
// no se usan al practicar; quedan por si faltan muestras. j, z y ñ llevan movimiento y no se reconocen.
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
    'i': (r) => [
      1 - r.ext[0],
      1 - r.ext[1],
      1 - r.ext[2],
      1 - r.ext[3],
      r.ext[4],
    ],
    'l': (r) => [r.ext[0], r.ext[1], 1 - r.ext[2], 1 - r.ext[3], 1 - r.ext[4]],
    'o': (r) => [r.cont[0], r.cont[1], r.cont[2]],
    // Índice y medio en V hacia abajo, con el pulgar en la base del medio.
    'p': (r) => [..._ve(r), r.pulgarEnMedio, r.abajo],
    'r': (r) => [..._ve(r), r.cruce],
    'v': (r) => [1 - r.ext[0], ..._ve(r), r.separacion, 1 - r.cruce],
    'w': (r) => [1 - r.ext[0], r.ext[1], r.ext[2], r.ext[3], 1 - r.ext[4]],
    'y': (r) => [r.ext[0], 1 - r.ext[1], 1 - r.ext[2], 1 - r.ext[3], r.ext[4]],
  };

  /// Letras (minúsculas) que se pueden practicar.
  static Iterable<String> get letrasSoportadas => _condiciones.keys;

  /// Confianza de que la mano forma [letra], o null si no la forma o la mano
  /// está incompleta.
  ClasificacionSena? puntuar(
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
    return ClasificacionSena(
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
}
