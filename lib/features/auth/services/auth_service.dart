import 'package:supabase_flutter/supabase_flutter.dart';

/// Wrapper delgado sobre Supabase Auth. No guarda estado propio: la fuente
/// de verdad de la sesión es siempre supabase.auth.
class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  /// Registra una cuenta nueva. El 'nombre' viaja en `data`, que es lo que
  /// el trigger on_auth_user_created lee para crear la fila en
  /// public.usuario automáticamente (ver schema_supabase.sql).
  Future<AuthResponse> registrarse({
    required String nombre,
    required String correo,
    required String contrasena,
  }) {
    return _client.auth.signUp(
      email: correo,
      password: contrasena,
      data: {'nombre': nombre},
    );
  }

  Future<AuthResponse> iniciarSesion({
    required String correo,
    required String contrasena,
  }) {
    return _client.auth.signInWithPassword(email: correo, password: contrasena);
  }

  Future<void> cerrarSesion() => _client.auth.signOut();

  /// null si no hay sesión activa.
  User? get usuarioActual => _client.auth.currentUser;

  /// Útil para un StreamBuilder que decida qué pantalla mostrar
  /// (login vs. home) según si hay sesión.
  Stream<AuthState> get cambiosDeSesion => _client.auth.onAuthStateChange;
}
