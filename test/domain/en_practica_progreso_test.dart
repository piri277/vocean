import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';

void main() {
  final hoy = DateTime(2026, 11, 12, 18);

  test('faltan días hasta dominar', () {
    expect(EnPractica(0, hoy).diasRestantes, 3);
    expect(EnPractica(1, hoy).diasRestantes, 2);
    expect(EnPractica(5, hoy).diasRestantes, 0);
  });

  test('hoy cuenta solo si hubo acierto hoy', () {
    expect(EnPractica(1, DateTime(2026, 11, 12)).contoHoy(hoy), isTrue);
    expect(EnPractica(1, DateTime(2026, 11, 11)).contoHoy(hoy), isFalse);
    // Sin aciertos la fecha es un relleno, no un día practicado.
    expect(EnPractica(0, DateTime(2026, 11, 12)).contoHoy(hoy), isFalse);
  });
}
