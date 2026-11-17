import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Guarda la sesión de Supabase (access y refresh token) cifrada: en Android
/// con una llave del Keystore y en iOS en el Keychain. Por defecto
/// supabase_flutter la guarda en texto plano en SharedPreferences.
class SesionSegura extends LocalStorage {
  SesionSegura({
    required this.clave,
    FlutterSecureStorage? almacen,
    LocalStorage? anterior,
  }) : _almacen = almacen ?? const FlutterSecureStorage(),
       _anterior = anterior ?? SharedPreferencesLocalStorage(persistSessionKey: clave);

  /// Misma clave que usa supabase_flutter: `sb-<ref>-auth-token`.
  final String clave;
  final FlutterSecureStorage _almacen;

  /// Almacén en texto plano de versiones anteriores de la app.
  final LocalStorage _anterior;

  /// Mueve una sesión vieja de SharedPreferences al almacén cifrado y la borra
  /// de SharedPreferences, para no dejar el token en texto plano.
  @override
  Future<void> initialize() async {
    await _anterior.initialize();
    final vieja = await _anterior.accessToken();
    if (vieja == null) return;
    if (!await hasAccessToken()) await persistSession(vieja);
    await _anterior.removePersistedSession();
  }

  @override
  Future<bool> hasAccessToken() => _almacen.containsKey(key: clave);

  @override
  Future<String?> accessToken() => _almacen.read(key: clave);

  @override
  Future<void> removePersistedSession() => _almacen.delete(key: clave);

  @override
  Future<void> persistSession(String persistSessionString) =>
      _almacen.write(key: clave, value: persistSessionString);
}
