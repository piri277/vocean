import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/senas/models/landmark_model.dart';
import 'package:miapp/features/senas/providers/practica_provider.dart';

List<Landmark> cuadrado(double cx, double lado) => [
  Landmark(x: cx - lado / 2, y: 0.5 - lado / 2, z: 0),
  Landmark(x: cx + lado / 2, y: 0.5 + lado / 2, z: 0),
];

void main() {
  test('manoPrincipal elige la mano más grande', () {
    final chica = cuadrado(0.2, 0.1), grande = cuadrado(0.7, 0.3);
    expect(manoPrincipal([chica, grande]), same(grande));
    expect(manoPrincipal([grande, chica]), same(grande));
    expect(manoPrincipal(const []), isNull);
  });

  test('suavizar mezcla con la anterior y se reinicia sin previa', () {
    final a = [const Landmark(x: 0, y: 0, z: 0)];
    final b = [const Landmark(x: 1, y: 1, z: 1)];
    expect(suavizar(null, b), same(b));
    expect(suavizar(a, b).single, const Landmark(x: 0.5, y: 0.5, z: 0.5));
  });
}
