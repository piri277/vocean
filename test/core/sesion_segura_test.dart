import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/core/storage/sesion_segura.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Sustituto de SharedPreferences: guarda en un mapa en memoria.
class _AlmacenPlano extends LocalStorage {
  _AlmacenPlano([this.valor]);
  String? valor;

  @override
  Future<void> initialize() async {}
  @override
  Future<bool> hasAccessToken() async => valor != null;
  @override
  Future<String?> accessToken() async => valor;
  @override
  Future<void> removePersistedSession() async => valor = null;
  @override
  Future<void> persistSession(String s) async => valor = s;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const clave = 'sb-test-auth-token';

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('H-05: guarda la sesión en el almacén seguro, no en texto plano', () async {
    final plano = _AlmacenPlano();
    final sesion = SesionSegura(clave: clave, anterior: plano);
    await sesion.initialize();

    await sesion.persistSession('{"refresh_token":"r"}');

    expect(await sesion.accessToken(), '{"refresh_token":"r"}');
    expect(plano.valor, isNull);
  });

  test('H-05: migra la sesión vieja y la borra de SharedPreferences', () async {
    final plano = _AlmacenPlano('{"refresh_token":"viejo"}');
    final sesion = SesionSegura(clave: clave, anterior: plano);

    await sesion.initialize();

    expect(await sesion.accessToken(), '{"refresh_token":"viejo"}');
    expect(plano.valor, isNull);
  });

  test('H-05: cerrar sesión borra el token', () async {
    final sesion = SesionSegura(clave: clave, anterior: _AlmacenPlano());
    await sesion.initialize();
    await sesion.persistSession('x');

    await sesion.removePersistedSession();

    expect(await sesion.hasAccessToken(), isFalse);
  });
}
