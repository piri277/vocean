import 'package:miapp/core/utils/json_utils.dart';

/// En qué punto del aprendizaje está una seña para el usuario.
///
/// `sealed` significa dos cosas: nadie fuera de este archivo puede añadir un
/// estado, y el compilador conoce la lista completa. Eso es lo que hace que
/// los `switch` de abajo puedan ser exhaustivos sin `default`.
sealed class EstadoAprendizaje {
  const EstadoAprendizaje();

  /// El ÚNICO sitio donde un texto del JSON se convierte en un tipo.
  factory EstadoAprendizaje.fromJson(Map<String, dynamic> json) {
    final tipo = leerTexto(json, 'tipo');
    return switch (tipo) {
      'no_iniciada' => const NoIniciada(),
      'en_practica' => EnPractica(
        leerEntero(json, 'intentos'),
        leerFecha(json, 'ultimoIntento'),
      ),
      'dominada' => Dominada(
        leerFecha(json, 'fechaDominada'),
        leerDecimal(json, 'precision'),
      ),
      'necesita_repaso' => NecesitaRepaso(
        leerTexto(json, 'motivo'),
        leerEntero(json, 'diasSinPracticar'),
      ),
      _ => throw CampoInvalido(
        'estadoAprendizaje.tipo',
        'no es un estado conocido',
        tipo,
      ),
    };
  }

  /// Y el único sitio donde vuelve a ser texto. Simétrico a fromJson: si
  /// añades un estado arriba y olvidas añadirlo aquí, esto no compila.
  Map<String, dynamic> toJson() => switch (this) {
    NoIniciada() => {'tipo': 'no_iniciada'},
    EnPractica(:final intentos, :final ultimoIntento) => {
      'tipo': 'en_practica',
      'intentos': intentos,
      'ultimoIntento': ultimoIntento.toIso8601String(),
    },
    Dominada(:final fechaDominada, :final precision) => {
      'tipo': 'dominada',
      'fechaDominada': fechaDominada.toIso8601String(),
      'precision': precision,
    },
    NecesitaRepaso(:final motivo, :final diasSinPracticar) => {
      'tipo': 'necesita_repaso',
      'motivo': motivo,
      'diasSinPracticar': diasSinPracticar,
    },
  };

  /// Regla de negocio: ¿esta seña debería aparecer en la sección "necesitas
  /// practicar" de la app?
  bool get necesitaAtencion => switch (this) {
    EnPractica() || NecesitaRepaso() => true,
    NoIniciada() || Dominada() => false,
  };

  /// Texto para la pantalla.
  String get etiqueta => switch (this) {
    NoIniciada() => 'Sin iniciar',
    EnPractica(:final intentos) => 'En práctica · $intentos intentos',
    Dominada(:final precision) =>
      'Dominada · ${(precision * 100).round()}% de precisión',
    NecesitaRepaso(:final motivo) => 'Necesita repaso: $motivo',
  };
}

final class NoIniciada extends EstadoAprendizaje {
  const NoIniciada();

  @override
  bool operator ==(Object other) => other is NoIniciada;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'NoIniciada()';
}

final class EnPractica extends EstadoAprendizaje {
  const EnPractica(this.intentos, this.ultimoIntento);

  final int intentos;
  final DateTime ultimoIntento;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnPractica &&
          other.intentos == intentos &&
          other.ultimoIntento == ultimoIntento;

  @override
  int get hashCode => Object.hash(runtimeType, intentos, ultimoIntento);

  @override
  String toString() => 'EnPractica($intentos, $ultimoIntento)';
}

final class Dominada extends EstadoAprendizaje {
  const Dominada(this.fechaDominada, this.precision)
    : assert(
        precision >= 0 && precision <= 1,
        'precision debe estar entre 0 y 1',
      );

  final DateTime fechaDominada;
  final double precision;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dominada &&
          other.fechaDominada == fechaDominada &&
          other.precision == precision;

  @override
  int get hashCode => Object.hash(runtimeType, fechaDominada, precision);

  @override
  String toString() => 'Dominada($fechaDominada, $precision)';
}

final class NecesitaRepaso extends EstadoAprendizaje {
  // El assert documenta la regla y la caza en depuración. La GARANTÍA es
  // leerTexto, que rechaza la cadena vacía también en producción.
  const NecesitaRepaso(this.motivo, this.diasSinPracticar)
    : assert(motivo != '', 'necesita_repaso exige motivo');

  final String motivo; // necesita_repaso SIN motivo no se puede ni escribir
  final int diasSinPracticar;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NecesitaRepaso &&
          other.motivo == motivo &&
          other.diasSinPracticar == diasSinPracticar;

  @override
  int get hashCode => Object.hash(runtimeType, motivo, diasSinPracticar);

  @override
  String toString() => 'NecesitaRepaso($motivo, $diasSinPracticar)';
}
