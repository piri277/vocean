import 'package:miapp/features/juego/models/resumen_partida_model.dart';

/// Estado del usuario y su progreso general.
class Usuario {
  const Usuario({
    required this.xpTotal,
    required this.partidasJugadas,
    required this.rachaGlobalMaxima,
    required this.fechaUltimaActividad,
    this.nombre,
    this.rachaDias = 0,
    this.ultimaPractica,
  });

  final int xpTotal;
  final int partidasJugadas;
  final int rachaGlobalMaxima;
  final DateTime fechaUltimaActividad;
  final String? nombre;

  /// Días seguidos practicando hasta [ultimaPractica] (fecha local, sin hora).
  final int rachaDias;
  final DateTime? ultimaPractica;

  /// Racha a mostrar [hoy]: se pierde si no se practicó ni hoy ni ayer.
  int rachaVigente(DateTime hoy) {
    final ultima = ultimaPractica;
    if (ultima == null) return 0;
    // En UTC para que un cambio de horario no altere la cuenta de días.
    final dias = DateTime.utc(
      hoy.year,
      hoy.month,
      hoy.day,
    ).difference(DateTime.utc(ultima.year, ultima.month, ultima.day)).inDays;
    return dias <= 1 ? rachaDias : 0;
  }

  /// Días de la racha que se perdió por no practicar ayer ni hoy; 0 si sigue viva.
  int rachaPerdida(DateTime hoy) =>
      ultimaPractica != null && rachaVigente(hoy) == 0 ? rachaDias : 0;

  Usuario copyWith({
    int? xpTotal,
    int? partidasJugadas,
    int? rachaGlobalMaxima,
    DateTime? fechaUltimaActividad,
    String? nombre,
    int? rachaDias,
    DateTime? ultimaPractica,
  }) => Usuario(
    xpTotal: xpTotal ?? this.xpTotal,
    partidasJugadas: partidasJugadas ?? this.partidasJugadas,
    rachaGlobalMaxima: rachaGlobalMaxima ?? this.rachaGlobalMaxima,
    fechaUltimaActividad: fechaUltimaActividad ?? this.fechaUltimaActividad,
    nombre: nombre ?? this.nombre,
    rachaDias: rachaDias ?? this.rachaDias,
    ultimaPractica: ultimaPractica ?? this.ultimaPractica,
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
          other.nombre == nombre &&
          other.rachaDias == rachaDias &&
          other.ultimaPractica == ultimaPractica;

  @override
  int get hashCode => Object.hash(
    xpTotal,
    partidasJugadas,
    rachaGlobalMaxima,
    fechaUltimaActividad,
    nombre,
    rachaDias,
    ultimaPractica,
  );

  @override
  String toString() =>
      'Usuario(xpTotal: $xpTotal, partidasJugadas: $partidasJugadas, rachaGlobalMaxima: $rachaGlobalMaxima, fechaUltimaActividad: $fechaUltimaActividad)';
}
