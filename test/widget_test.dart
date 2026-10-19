import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/auth/providers/auth_providers.dart';
import 'package:miapp/features/auth/services/auth_service.dart';
import 'package:miapp/main.dart';

class _AuthServiceFalso implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  @override
  get usuarioActual => null;
}

void main() {
  testWidgets('la app inicia mostrando la pantalla de login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authServiceProvider.overrideWithValue(_AuthServiceFalso())],
        child: const MyApp(),
      ),
    );

    expect(find.text('VOCEAN'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
