import 'package:miapp/core/json.dart';
import 'package:miapp/features/senas/domain/estado_aprendizaje.dart';
import 'package:miapp/features/senas/domain/posicion_mano.dart';

/// Una seña del diccionario.
///
/// Es una **entidad**: tiene identidad propia. Dos señas con el mismo nombre
/// son dos señas distintas si tienen `id` distinto (ej. dos dialectos
/// regionales de la misma palabra).
class Sena {
  const Sena({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.descripcion,
    required this.posicionReferencia,
    required this.estadoAprendizaje,
    this.videoReferencia,
  });

  factory Sena.fromJson(Map<String, dynamic> json) => Sena(
    id: leerTexto(json, 'id'),
    nombre: leerTexto(json, 'nombre'),
    categoria: leerTexto(json, 'categoria'),
    descripcion: leerTexto(json, 'descripcion'),
    posicionReferencia: PosicionMano.fromJson(
      leerMapa(json, 'posicionReferencia'),
    ),
    estadoAprendizaje: EstadoAprendizaje.fromJson(
      leerMapa(json, 'estadoAprendizaje'),
    ),
    videoReferencia: leerTextoOpcional(json, 'videoReferencia'),
  );

  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final PosicionMano posicionReferencia;
  final EstadoAprendizaje estadoAprendizaje;
  final String? videoReferencia;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'categoria': categoria,
    'descripcion': descripcion,
    'posicionReferencia': posicionReferencia.toJson(),
    'estadoAprendizaje': estadoAprendizaje.toJson(),
    if (videoReferencia != null) 'videoReferencia': videoReferencia,
  };

  // ── Reglas de negocio ───────────────────────────────────────────────────

  bool get tieneVideo => videoReferencia != null;

  /// Depende solo de los campos: no necesita reloj ni parámetros externos.
  bool get requierePractica => estadoAprendizaje.necesitaAtencion;

  /// El reloj entra como parámetro, no se lee dentro.
  ///
  /// Con `DateTime.now()` dentro, esta regla no se puede probar: el resultado
  /// dependería del día en que se corra la prueba.
  ///
  /// Devuelve null si la seña no está dominada (no aplica repasar algo que
  /// nunca se aprendió).
  Duration? tiempoDesdeDominada(DateTime ahora) => switch (estadoAprendizaje) {
    Dominada(:final fechaDominada) => ahora.difference(fechaDominada),
    _ => null,
  };

  /// Recomienda repaso si han pasado más de 14 días desde que se dominó.
  bool debeRecomendarRepaso(DateTime ahora) {
    final tiempo = tiempoDesdeDominada(ahora);
    return tiempo != null && tiempo > const Duration(days: 14);
  }

  // ── Copia ───────────────────────────────────────────────────────────────

  Sena copyWith({
    String? nombre,
    String? categoria,
    String? descripcion,
    PosicionMano? posicionReferencia,
    EstadoAprendizaje? estadoAprendizaje,
    String? videoReferencia,
  }) => Sena(
    id: id, // la identidad NO se copia con cambios
    nombre: nombre ?? this.nombre,
    categoria: categoria ?? this.categoria,
    descripcion: descripcion ?? this.descripcion,
    posicionReferencia: posicionReferencia ?? this.posicionReferencia,
    estadoAprendizaje: estadoAprendizaje ?? this.estadoAprendizaje,
    videoReferencia: videoReferencia ?? this.videoReferencia,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sena &&
          other.id == id &&
          other.nombre == nombre &&
          other.categoria == categoria &&
          other.descripcion == descripcion &&
          other.posicionReferencia == posicionReferencia &&
          other.estadoAprendizaje == estadoAprendizaje &&
          other.videoReferencia == videoReferencia;

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    categoria,
    descripcion,
    posicionReferencia,
    estadoAprendizaje,
    videoReferencia,
  );

  @override
  String toString() => 'Sena($id, $nombre, ${estadoAprendizaje.etiqueta})';
}
