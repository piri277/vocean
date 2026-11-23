import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/auth/providers/auth_providers.dart';
import 'package:miapp/features/auth/providers/auth_state.dart';
import 'package:miapp/features/auth/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class _AuthServiceFalso implements AuthService {
  final cambios = StreamController<sb.AuthState>();
  bool abreNavegador = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  sb.User? get usuarioActual => null;

  @override
  Stream<sb.AuthState> get cambiosDeSesion => cambios.stream;

  @override
  Future<bool> iniciarConGoogle() async => abreNavegador;
}

sb.Session _sesion(String correo) => sb.Session(
  accessToken: 'token',
  tokenType: 'bearer',
  user: sb.User(
    id: '1',
    appMetadata: const {},
    userMetadata: const {},
    aud: 'authenticated',
    createdAt: '2026-01-01',
    email: correo,
  ),
);

void main() {
  test('Google: abre navegador y autentica al llegar el deep link', () async {
    final servicio = _AuthServiceFalso();
    final notifier = AuthNotifier(servicio);

    await notifier.loginConGoogle();
    expect(notifier.state, isA<AuthInitial>());

    servicio.cambios.add(
      sb.AuthState(sb.AuthChangeEvent.signedIn, _sesion('ana@gmail.com')),
    );
    await Future<void>.delayed(Duration.zero);

    final estado = notifier.state;
    expect(estado, isA<AuthAuthenticated>());
    expect((estado as AuthAuthenticated).email, 'ana@gmail.com');
    notifier.dispose();
  });

  test('Google: error si no se puede abrir el navegador', () async {
    final servicio = _AuthServiceFalso()..abreNavegador = false;
    final notifier = AuthNotifier(servicio);

    await notifier.loginConGoogle();
    expect(notifier.state, isA<AuthError>());
    notifier.dispose();
  });
}
