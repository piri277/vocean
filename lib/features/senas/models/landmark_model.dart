import 'package:miapp/core/utils/json_utils.dart';

/// Punto detectado por la cámara para evaluar una posición manual.
class Landmark {
  const Landmark({required this.x, required this.y, required this.z});

  factory Landmark.fromJson(Map<String, dynamic> json) => Landmark(
    x: leerDecimal(json, 'x'),
    y: leerDecimal(json, 'y'),
    z: leerDecimal(json, 'z'),
  );

  final double x;
  final double y;
  final double z;

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Landmark && other.x == x && other.y == y && other.z == z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => 'Landmark(x: $x, y: $y, z: $z)';
}
