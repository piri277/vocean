import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:miapp/features/home/views/bienvenida_animada.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('la bienvenida espera la carga y luego termina', (tester) async {
    final carga = Completer<void>();
    var terminada = false;
    await tester.pumpWidget(
      MaterialApp(
        home: BienvenidaAnimada(
          cargando: carga.future,
          alTerminar: () => terminada = true,
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    expect(terminada, isFalse, reason: 'aún no termina de cargar');

    carga.complete();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(terminada, isTrue);
  });
}
