import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/cultura/data/contenido_lsc.dart';
import 'package:miapp/features/cultura/views/quiz_cultura.dart';
import 'package:miapp/features/perfil/providers/perfil_provider.dart';
import '../../helpers/repo_usuario_falso.dart';

void main() {
  test('los temas coinciden con TEMAS_CULTURA del backend', () {
    expect(
      {for (final t in temasLsc) t.id, 'mitos'},
      {
        'linea-tiempo',
        'derechos',
        'lengua',
        'comunidad',
        'comunicacion',
        'curiosos',
        'mitos',
      },
    );
  });

  test('cada pregunta tiene su respuesta correcta entre las opciones', () {
    final todas = [for (final t in temasLsc) ...t.quiz, ...mitosLsc];
    for (final p in todas) {
      expect(p.correcta, inInclusiveRange(0, p.opciones.length - 1));
    }
    for (final t in temasLsc) {
      expect(t.quiz.length, greaterThanOrEqualTo(4), reason: t.id);
      expect(t.datos, isNotEmpty, reason: t.id);
    }
  });

  test('el dato del día tiene más de 50 opciones', () {
    final todos = [for (final t in temasLsc) ...t.datos, ...datosDelDiaExtra];
    expect(todos.length, greaterThan(50));
  });

  testWidgets('en repaso no se envía el resultado al backend', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final repo = RepoUsuarioFalso();
    final tema = temasLsc.first;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [usuarioRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: QuizCultura(
            temaId: tema.id,
            titulo: 'Quiz',
            preguntas: tema.quiz.take(1).toList(),
            completado: true,
          ),
        ),
      ),
    );
    expect(
      find.text('Tema completado. Este repaso ya no da XP.'),
      findsOneWidget,
    );
    final p = tema.quiz.first;
    await tester.tap(find.text(p.opciones[p.correcta]));
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Ver resultado'), 200);
    await tester.tap(find.text('Ver resultado'));
    await tester.pumpAndSettle();
    expect(repo.quizzes, isEmpty);
    expect(find.text('Repaso: la XP de este tema ya es tuya'), findsOneWidget);
  });

  testWidgets('responder bien todo el quiz envía el resultado y muestra XP', (
    tester,
  ) async {
    final repo = RepoUsuarioFalso();
    final tema = temasLsc.first;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [usuarioRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: QuizCultura(
            temaId: tema.id,
            titulo: 'Quiz',
            preguntas: tema.quiz,
          ),
        ),
      ),
    );
    await tester.pump();

    for (var i = 0; i < tema.quiz.length; i++) {
      // La pregunta en pantalla dice cuál es la opción correcta.
      final enunciado = tema.quiz.firstWhere(
        (p) => find.text(p.enunciado).evaluate().isNotEmpty,
      );
      await tester.tap(find.text(enunciado.opciones[enunciado.correcta]));
      await tester.pump();
      expect(find.text('¡Correcto!'), findsOneWidget);
      await tester.tap(
        find.text(i == tema.quiz.length - 1 ? 'Ver resultado' : 'Siguiente'),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(repo.quizzes, [(tema.id, tema.quiz.length, tema.quiz.length)]);
    expect(find.text('¡Muy bien!'), findsOneWidget);
    expect(find.text('+15 XP'), findsOneWidget);
  });
}
