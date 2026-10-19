import 'package:miapp/features/juego/models/resumen_partida_model.dart';

/// Estado del usuario y su progreso general.
class Usuario {
  const Usuario({
    required this.xpTotal,
    required this.partidasJugadas,
    required this.rachaGlobalMaxima,
    required this.fechaUltimaActividad,
    this.nombre,
  });

  final int xpTotal;
  final int partidasJugadas;
  final int rachaGlobalMaxima;
  final DateTime fechaUltimaActividad;
  final String? nombre;

  Usuario copyWith({
    int? xpTotal,
    int? partidasJugadas,
    int? rachaGlobalMaxima,
    DateTime? fechaUltimaActividad,
    String? nombre,
  }) => Usuario(
    xpTotal: xpTotal ?? this.xpTotal,
    partidasJugadas: partidasJugadas ?? this.partidasJugadas,
    rachaGlobalMaxima: rachaGlobalMaxima ?? this.rachaGlobalMaxima,
    fechaUltimaActividad: fechaUltimaActividad ?? this.fechaUltimaActividad,
    nombre: nombre ?? this.nombre,
  );

  Usuario registrarPartida(ResumenPartida resumen) => copyWith(
    xpTotal: xpTotal + resumen.xpGanado,
    partidasJugadas: partidasJugadas + 1,
    rachaGlobalMaxima: rachaGlobalMaxima > resumen.rachaMaxima
        ? rachaGlobalMaxima
        : resumen.rachaMaxima,
    fechaUltimaActividad: DateTime.now(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Usuario &&
          other.xpTotal == xpTotal &&
          other.partidasJugadas == partidasJugadas &&
          other.rachaGlobalMaxima == rachaGlobalMaxima &&
          other.fechaUltimaActividad == fechaUltimaActividad &&
          other.nombre == nombre;

  @override
  int get hashCode => Object.hash(
    xpTotal,
    partidasJugadas,
    rachaGlobalMaxima,
    fechaUltimaActividad,
    nombre,
  );

  @override
  String toString() =>
      'Usuario(xpTotal: $xpTotal, partidasJugadas: $partidasJugadas, rachaGlobalMaxima: $rachaGlobalMaxima, fechaUltimaActividad: $fechaUltimaActividad)';
}
