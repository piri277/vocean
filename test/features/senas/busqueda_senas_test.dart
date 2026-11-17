import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/senas/views/widgets/icono_categoria.dart';

void main() {
  test('la búsqueda ignora mayúsculas y tildes', () {
    expect(normalizarBusqueda('  Número Ú '), 'numero u');
    expect(normalizarBusqueda('Número').contains(normalizarBusqueda('nume')), isTrue);
  });

  test('imagen de seña según su id', () {
    expect(imagenDeSena('num-3'), 'assets/numeros/3.png');
    expect(imagenDeSena('alfa-b'), 'assets/letras/b.png');
  });
}
