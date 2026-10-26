import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/perfil/models/usuario_model.dart';

Usuario conRacha(int dias, DateTime? ultima) => Usuario(
  xpTotal: 0,
  partidasJugadas: 0,
  rachaGlobalMaxima: 0,
  fechaUltimaActividad: DateTime(2026),
  rachaDias: dias,
  ultimaPractica: ultima,
);

void main() {
  final hoy = DateTime(2026, 10, 26, 21, 30);

  test('sin prácticas la racha es 0', () {
    expect(conRacha(0, null).rachaVigente(hoy), 0);
  });

  test('se mantiene si practicó hoy o ayer', () {
    expect(conRacha(4, DateTime(2026, 10, 26)).rachaVigente(hoy), 4);
    expect(conRacha(4, DateTime(2026, 10, 25)).rachaVigente(hoy), 4);
  });

  test('se pierde si pasó más de un día', () {
    expect(conRacha(4, DateTime(2026, 10, 24)).rachaVigente(hoy), 0);
  });
}
