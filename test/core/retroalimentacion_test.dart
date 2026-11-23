import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miapp/core/widgets/retroalimentacion.dart';

Widget _opcion(Respuesta? r) => MaterialApp(
  home: Center(
    child: AnimacionRespuesta(
      resultado: r,
      child: const SizedBox(width: 100, height: 40, child: Text('A')),
    ),
  ),
);

void main() {
  testWidgets('la opción correcta no cambia de tamaño en una cuadrícula', (
    tester,
  ) async {
    Widget celda(Respuesta? r) => MaterialApp(
      home: GridView.count(
        crossAxisCount: 2,
        children: [
          AnimacionRespuesta(
            resultado: r,
            child: const ColoredBox(
              key: Key('celda'),
              color: Colors.red,
              child: Text('B'),
            ),
          ),
        ],
      ),
    );
    await tester.pumpWidget(celda(null));
    final antes = tester.getSize(find.byKey(const Key('celda')));
    await tester.pumpWidget(celda(Respuesta.correcta));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const Key('celda'))), antes);
  });

  testWidgets('la opción incorrecta tiembla y vuelve a su lugar', (
    tester,
  ) async {
    await tester.pumpWidget(_opcion(null));
    final inicio = tester.getTopLeft(find.text('A'));

    await tester.pumpWidget(_opcion(Respuesta.incorrecta));
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.getTopLeft(find.text('A')).dx, isNot(inicio.dx));

    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text('A')), inicio);
  });

  testWidgets('la opción correcta salta y las chispas desaparecen', (
    tester,
  ) async {
    await tester.pumpWidget(_opcion(null));
    await tester.pumpWidget(_opcion(Respuesta.correcta));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(CustomPaint), findsWidgets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('el confeti del final cae una sola vez y termina', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CelebracionFinal(gano: true, child: Text('¡Ganaste!')),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('¡Ganaste!'), findsOneWidget);
    // pumpAndSettle termina: ninguna animación se repite.
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
