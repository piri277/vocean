import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/core/widgets/cuadricula_dos.dart';
import 'package:miapp/features/senas/views/diccionario_view.dart';

void main() {
  testWidgets('las tarjetas de categoría no se desbordan con letra grande', (
    tester,
  ) async {
    // Pantalla angosta (360 dp) y letra del sistema a 1.3x.
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 800),
          textScaler: TextScaler.linear(1.3),
        ),
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: CuadriculaDos(
                children: [
                  for (final c in [
                    'Alfabeto',
                    'Números',
                    'Saludos',
                    'Emergencias',
                  ])
                    CategoriaTile(categoria: c, categoriaSenas: const []),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Emergencias'), findsOneWidget);
  });
}
