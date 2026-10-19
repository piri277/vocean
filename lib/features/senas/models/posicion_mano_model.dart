import 'package:miapp/core/utils/comparaciones_utils.dart';
import 'package:miapp/core/utils/json_utils.dart';

/// Cómo debe verse la mano para que una seña se considere correcta.
///
/// Es un **objeto de valor**: dos posiciones con los mismos landmarks y los
/// mismos ángulos son la misma posición, así que no lleva `id` y se compara
/// por contenido.
class PosicionMano {
  const PosicionMano({
    required this.landmarksClave,
    required this.anguloPulgar,
    required this.distanciaIndiceMedio,
  });

  factory PosicionMano.fromJson(Map<String, dynamic> json) => PosicionMano(
    landmarksClave: leerEnteros(json, 'landmarksClave'),
    anguloPulgar: leerDecimal(json, 'anguloPulgar'),
    distanciaIndiceMedio: leerDecimal(json, 'distanciaIndiceMedio'),
  );

  /// Índices de los 21 puntos de MediaPipe Hands que importan para esta seña.
  final List<int> landmarksClave;

  /// Ángulo del pulgar respecto al índice, en grados.
  final double anguloPulgar;

  /// Distancia normalizada entre la punta del índice y la del medio.
  final double distanciaIndiceMedio;

  Map<String, dynamic> toJson() => {
    'landmarksClave': landmarksClave,
    'anguloPulgar': anguloPulgar,
    'distanciaIndiceMedio': distanciaIndiceMedio,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PosicionMano &&
          listasIguales(other.landmarksClave, landmarksClave) &&
          other.anguloPulgar == anguloPulgar &&
          other.distanciaIndiceMedio == distanciaIndiceMedio;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(landmarksClave),
    anguloPulgar,
    distanciaIndiceMedio,
  );

  @override
  String toString() =>
      'PosicionMano(landmarks: $landmarksClave, pulgar: $anguloPulgar°, indiceMedio: $distanciaIndiceMedio)';
}
