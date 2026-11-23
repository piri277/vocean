import 'dart:math';

import 'package:miapp/features/juego/models/dificultad_model.dart';

/// Qué textos entran en la partida.
enum CategoriaJuego { palabras, numeros, mezcla }

/// Una ronda: la respuesta y sus 4 opciones (la correcta incluida).
///
/// Si [inversa], se muestra el texto y se elige entre secuencias de señas.
class PreguntaJuego {
  const PreguntaJuego(this.respuesta, this.opciones, {this.inversa = false});

  final String respuesta;
  final List<String> opciones;
  final bool inversa;
}

/// Preguntas del reto diario: 5 por día, iguales para todos.
const preguntasReto = 5;

/// Dificultad de cada pregunta del reto: sube de a poco.
const _dificultadReto = [
  Dificultad.facil,
  Dificultad.medio,
  Dificultad.medio,
  Dificultad.dificil,
  Dificultad.extremo,
];

bool esNumero(String s) => RegExp(r'\d').hasMatch(s);

/// Arma las preguntas del juego a partir de `assets/juego/palabras.json`
/// (categoría → dificultad → textos).
class BancoJuego {
  const BancoJuego(this.datos);

  final Map<String, Map<String, List<String>>> datos;

  List<String> nivel(String categoria, Dificultad d) =>
      datos[categoria]?[d.name] ?? const [];

  List<String> textos(CategoriaJuego c, Dificultad d) => switch (c) {
    CategoriaJuego.palabras => nivel('palabras', d),
    CategoriaJuego.numeros => nivel('numeros', d),
    CategoriaJuego.mezcla => [...nivel('palabras', d), ...nivel('numeros', d)],
  };

  /// La correcta y 3 distractores del mismo tipo y de largo parecido.
  List<String> opciones(String correcta, Random rnd) {
    final pool = [
      for (final n
          in datos[esNumero(correcta) ? 'numeros' : 'palabras']!.values)
        ...n,
    ].where((p) => p != correcta).toSet().toList()..shuffle(rnd);
    pool.sort(
      (a, b) => (a.length - correcta.length).abs().compareTo(
        (b.length - correcta.length).abs(),
      ),
    );
    return [correcta, ...pool.take(3)]..shuffle(rnd);
  }

  PreguntaJuego pregunta(String correcta, Random rnd, {bool inversa = false}) =>
      PreguntaJuego(correcta, opciones(correcta, rnd), inversa: inversa);

  /// Partida normal de [rondas] preguntas. Con [peso], los textos de más peso
  /// tienen más probabilidad de salir (repaso inteligente).
  List<PreguntaJuego> partida({
    required CategoriaJuego categoria,
    required Dificultad dificultad,
    required int rondas,
    required Random rnd,
    bool inversa = false,
    double Function(String texto)? peso,
  }) {
    final elegidos = ordenar(textos(categoria, dificultad), rnd, peso);
    return [
      for (final t in elegidos.take(rondas)) pregunta(t, rnd, inversa: inversa),
    ];
  }

  /// Orden al azar; con [peso], ponderado (Efraimidis–Spirakis): un texto
  /// con el doble de peso tiende a salir antes.
  static List<String> ordenar(
    List<String> textos,
    Random rnd, [
    double Function(String texto)? peso,
  ]) {
    if (peso == null) return [...textos]..shuffle(rnd);
    final clave = {
      for (final t in textos)
        t: -log(1 - rnd.nextDouble()) / max(peso(t), 0.01),
    };
    return [...textos]..sort((a, b) => clave[a]!.compareTo(clave[b]!));
  }

  /// En supervivencia la dificultad sube cada 5 aciertos.
  static Dificultad dificultadSupervivencia(int aciertos) =>
      Dificultad.values[min(aciertos ~/ 5, Dificultad.values.length - 1)];

  /// Siguiente pregunta de supervivencia, sin repetir las [usadas] mientras
  /// queden otras.
  PreguntaJuego preguntaSupervivencia({
    required CategoriaJuego categoria,
    required int aciertos,
    required Set<String> usadas,
    required Random rnd,
    bool inversa = false,
    double Function(String texto)? peso,
  }) {
    final todos = textos(categoria, dificultadSupervivencia(aciertos));
    final libres = todos.where((t) => !usadas.contains(t)).toList();
    final elegido = ordenar(libres.isEmpty ? todos : libres, rnd, peso).first;
    return pregunta(elegido, rnd, inversa: inversa);
  }

  /// Reto del día: la misma semilla (la fecha) da las mismas preguntas a todos.
  /// Mezcla palabras y números y alterna la dirección.
  List<PreguntaJuego> retoDiario(DateTime fecha) {
    final rnd = Random(fecha.year * 10000 + fecha.month * 100 + fecha.day);
    final usadas = <String>{};
    return [
      for (final (i, d) in _dificultadReto.indexed)
        () {
          final pool = [
            ...nivel('palabras', d),
            ...nivel('numeros', d),
          ].where((t) => !usadas.contains(t)).toList();
          final t = pool[rnd.nextInt(pool.length)];
          usadas.add(t);
          return pregunta(t, rnd, inversa: i.isOdd);
        }(),
    ];
  }
}

/// Clave con la que el backend marca el reto de [fecha] como jugado.
String claveReto(DateTime fecha) =>
    'reto:${fecha.toIso8601String().substring(0, 10)}';
