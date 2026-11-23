import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/features/cultura/data/contenido_lsc.dart';
import 'package:miapp/features/cultura/views/historias_tema.dart';

Future<void> _abrir(WidgetTester tester, {double letra = 1}) async {
  tester.view.physicalSize = const Size(1080, 2000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(letra)),
      child: MaterialApp(home: HistoriasTema(tema: temasLsc.first)),
    ),
  );
  await tester.pump();
}

void main() {
  final tema = temasLsc.first;

  testWidgets('al tocar la tarjeta se voltea y muestra la explicación', (
    tester,
  ) async {
    await _abrir(tester);
    expect(find.text(tema.datos.first.texto), findsNothing);

    await tester.tap(find.text(tema.datos.first.titulo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text(tema.datos.first.texto), findsOneWidget);
  });

  testWidgets('las flechas llegan hasta la tarjeta del quiz', (tester) async {
    await _abrir(tester);
    for (var i = 0; i < tema.datos.length; i++) {
      await tester.tap(find.byTooltip('Siguiente'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.text('Empezar quiz'), findsOneWidget);
    expect(find.text('Quiz'), findsOneWidget);
  });

  testWidgets('con letra grande las tarjetas no se desbordan', (tester) async {
    await _abrir(tester, letra: 1.3);
    await tester.tap(find.text(tema.datos.first.titulo));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
  });
}
