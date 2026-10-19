import 'package:miapp/core/utils/json_utils.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/models/posicion_mano_model.dart';

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
    this.imagenReferencia,
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
    imagenReferencia: leerTextoOpcional(json, 'imagenReferencia'),
  );

  final String id;
  final String nombre;
  final String categoria;
  final String descripcion;
  final PosicionMano posicionReferencia;
  final EstadoAprendizaje estadoAprendizaje;
  final String? imagenReferencia;

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'categoria': categoria,
    'descripcion': descripcion,
    'posicionReferencia': posicionReferencia.toJson(),
    'estadoAprendizaje': estadoAprendizaje.toJson(),
    if (imagenReferencia != null) 'imagenReferencia': imagenReferencia,
  };

  // ── Reglas de negocio ───────────────────────────────────────────────────

  bool get tieneImagen => imagenReferencia != null;

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
    String? imagenReferencia,
  }) => Sena(
    id: id, // la identidad NO se copia con cambios
    nombre: nombre ?? this.nombre,
    categoria: categoria ?? this.categoria,
    descripcion: descripcion ?? this.descripcion,
    posicionReferencia: posicionReferencia ?? this.posicionReferencia,
    estadoAprendizaje: estadoAprendizaje ?? this.estadoAprendizaje,
    imagenReferencia: imagenReferencia ?? this.imagenReferencia,
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
          other.imagenReferencia == imagenReferencia;

  @override
  int get hashCode => Object.hash(
    id,
    nombre,
    categoria,
    descripcion,
    posicionReferencia,
    estadoAprendizaje,
    imagenReferencia,
  );

  @override
  String toString() => 'Sena($id, $nombre, ${estadoAprendizaje.etiqueta})';
}
