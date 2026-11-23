import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/juego/views/juego_view.dart';
import 'package:miapp/features/perfil/providers/perfil_provider.dart';
import 'package:miapp/features/senas/providers/senas_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/repo_usuario_falso.dart';

const _espera = Duration(milliseconds: 400);

Future<RepoUsuarioFalso> _abrir(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  // El caché del asset guarda un Future de la prueba anterior que no termina.
  rootBundle.evict('assets/juego/palabras.json');
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final repo = RepoUsuarioFalso();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        usuarioRepositoryProvider.overrideWithValue(repo),
        senasFutureProvider.overrideWith((ref) async => []),
      ],
      child: const MaterialApp(home: JuegoView()),
    ),
  );
  // Carga de palabras.json (E/S real): espera a que salga el menú.
  for (
    var i = 0;
    i < 50 && find.text('Elige el juego').evaluate().isEmpty;
    i++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
  }
  return repo;
}

Future<void> _tocar(WidgetTester tester, Finder f) async {
  await tester.scrollUntilVisible(
    f,
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await tester.pump(_espera);
}

/// Primera opción de la ronda: una secuencia de señas o un texto.
Finder _primeraOpcion() {
  final senas = find.byWidgetPredicate(
    (w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('opcion-senas-'),
  );
  if (senas.evaluate().isNotEmpty) return senas.first;
  return find
      .byWidgetPredicate(
        (w) =>
            w is Text &&
            w.maxLines == 1 &&
            w.textAlign == TextAlign.center &&
            w.style?.fontSize == 18,
      )
      .first;
}

void main() {
  testWidgets('supervivencia termina al perder las 3 vidas', (tester) async {
    final repo = await _abrir(tester);
    await _tocar(tester, find.text('Supervivencia'));
    await _tocar(tester, find.text('Empezar'));

    // Siempre la primera opción: tarde o temprano falla 3 veces.
    for (var i = 0; i < 300; i++) {
      await _tocar(tester, _primeraOpcion());
      if (find.text('Ver resultado').evaluate().isNotEmpty) break;
      await _tocar(tester, find.text('Siguiente'));
    }
    await _tocar(tester, find.text('Ver resultado'));
    expect(find.text('Aciertos antes de perder las 3 vidas'), findsOneWidget);
    expect(find.text('Jugar de nuevo'), findsOneWidget);
    // El récord va al perfil (backend), no al teléfono.
    expect(repo.supervivencias, hasLength(1));
  });

  testWidgets('el reto diario se envía al backend una vez', (tester) async {
    final repo = await _abrir(tester);
    await _tocar(tester, find.text('Reto diario'));
    await _tocar(tester, find.text('Jugar el reto'));

    for (var i = 0; i < 5; i++) {
      await _tocar(tester, _primeraOpcion());
      await _tocar(tester, find.text(i == 4 ? 'Ver resultado' : 'Siguiente'));
    }
    await tester.pump(_espera);
    expect(repo.retos, hasLength(1));
    expect(repo.retos.single.$3, 5);
    expect(find.text('Volver al menú'), findsOneWidget);
  });
}
