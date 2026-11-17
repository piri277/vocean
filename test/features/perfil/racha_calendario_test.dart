import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/perfil/models/usuario_model.dart';
import 'package:miapp/features/perfil/views/racha_calendario.dart';

Usuario _usuario(int racha, DateTime? ultima) => Usuario(
  xpTotal: 0,
  partidasJugadas: 0,
  rachaGlobalMaxima: 0,
  fechaUltimaActividad: DateTime(2026),
  rachaDias: racha,
  ultimaPractica: ultima,
);

void main() {
  test('marca los días de la racha cruzando el cambio de mes', () {
    final dias = diasDeRacha(
      _usuario(3, DateTime(2026, 11, 1)),
      DateTime(2026, 11, 1),
    );
    expect(dias, {
      DateTime(2026, 11, 1),
      DateTime(2026, 10, 31),
      DateTime(2026, 10, 30),
    });
  });

  test('una racha vencida no marca días', () {
    expect(
      diasDeRacha(_usuario(5, DateTime(2026, 11, 1)), DateTime(2026, 11, 5)),
      isEmpty,
    );
  });

  test('racha perdida: tenía días y no practicó ni ayer ni hoy', () {
    final u = _usuario(4, DateTime(2026, 11, 1));
    expect(u.rachaPerdida(DateTime(2026, 11, 2)), 0);
    expect(u.rachaPerdida(DateTime(2026, 11, 3)), 4);
  });
}
