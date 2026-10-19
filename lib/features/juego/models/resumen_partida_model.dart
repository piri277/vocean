import 'package:miapp/features/juego/models/dificultad_model.dart';

/// Resumen final de una partida.
class ResumenPartida {
  const ResumenPartida({
    required this.dificultad,
    required this.puntuacion,
    required this.rachaMaxima,
    required this.xpGanado,
  });

  factory ResumenPartida.fromJson(Map<String, dynamic> json) => ResumenPartida(
    dificultad: Dificultad.values.firstWhere(
      (element) => element.name == json['dificultad'],
      orElse: () => Dificultad.facil,
    ),
    puntuacion: json['puntuacion'] as int? ?? 0,
    rachaMaxima: json['rachaMaxima'] as int? ?? 0,
    xpGanado: json['xpGanado'] as int? ?? 0,
  );

  final Dificultad dificultad;
  final int puntuacion;
  final int rachaMaxima;
  final int xpGanado;

  Map<String, dynamic> toJson() => {
    'dificultad': dificultad.name,
    'puntuacion': puntuacion,
    'rachaMaxima': rachaMaxima,
    'xpGanado': xpGanado,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumenPartida &&
          other.dificultad == dificultad &&
          other.puntuacion == puntuacion &&
          other.rachaMaxima == rachaMaxima &&
          other.xpGanado == xpGanado;

  @override
  int get hashCode =>
      Object.hash(dificultad, puntuacion, rachaMaxima, xpGanado);

  @override
  String toString() =>
      'ResumenPartida(dificultad: $dificultad, puntuacion: $puntuacion, rachaMaxima: $rachaMaxima, xpGanado: $xpGanado)';
}
