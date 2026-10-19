import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:miapp/features/auth/providers/auth_state.dart';
import 'package:miapp/features/auth/services/auth_service.dart';

/// Provider que expone la instancia activa del cliente Supabase.
final supabaseClientProvider = Provider<sb.SupabaseClient>((ref) {
  return sb.Supabase.instance.client;
});

/// Provider que inyecta el servicio de autenticación de Supabase.
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

/// Notifier que gestiona el estado de la autenticación llamando a Supabase Auth.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(const AuthInitial()) {
    _initSession();
  }

  final AuthService _authService;

  void _initSession() {
    final user = _authService.usuarioActual;
    if (user != null && user.email != null) {
      state = AuthAuthenticated(email: user.email!);
    }
  }

  Future<void> login({required String email, required String password}) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail.isEmpty || trimmedPassword.isEmpty) {
      state = const AuthError('Por favor, completa todos los campos');
      return;
    }

    if (!trimmedEmail.contains('@')) {
      state = const AuthError('Introduce un correo válido');
      return;
    }

    state = const AuthLoading();
    try {
      final res = await _authService.iniciarSesion(
        correo: trimmedEmail,
        contrasena: trimmedPassword,
      );
      final user = res.user;
      if (user != null) {
        state = AuthAuthenticated(email: user.email ?? trimmedEmail);
      } else {
        state = const AuthError('No se pudo verificar el usuario.');
      }
    } on sb.AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('Error al iniciar sesión: $e');
    }
  }

  Future<void> register({
    required String nombre,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final trimmedNombre = nombre.trim();
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();
    final trimmedConfirm = confirmPassword.trim();

    if (trimmedNombre.isEmpty ||
        trimmedEmail.isEmpty ||
        trimmedPassword.isEmpty ||
        trimmedConfirm.isEmpty) {
      state = const AuthError('Completa todos los campos para crear la cuenta');
      return;
    }

    if (!trimmedEmail.contains('@')) {
      state = const AuthError('Introduce un correo válido');
      return;
    }

    if (trimmedPassword.length < 6) {
      state = const AuthError('La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (trimmedPassword != trimmedConfirm) {
      state = const AuthError('Las contraseñas no coinciden');
      return;
    }

    state = const AuthLoading();
    try {
      final res = await _authService.registrarse(
        nombre: trimmedNombre,
        correo: trimmedEmail,
        contrasena: trimmedPassword,
      );
      final user = res.user;
      if (user == null) {
        state = const AuthError('No se pudo registrar el usuario.');
      } else if (res.session == null) {
        // Supabase con confirmación de correo activa: no hay sesión todavía.
        state = const AuthError('Revisa tu correo para confirmar la cuenta.');
      } else {
        state = AuthAuthenticated(email: user.email ?? trimmedEmail);
      }
    } on sb.AuthException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('Error al registrar usuario: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _authService.cerrarSesion();
    } catch (_) {}
    state = const AuthUnauthenticated();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authServiceProvider)),
);
