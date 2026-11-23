import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:miapp/features/home/views/bienvenida_animada.dart';

void main() {
  mainEspera();
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

  testWidgets('si la carga falla, la bienvenida igual termina', (tester) async {
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
    carga.completeError(TimeoutException('lento'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 1));
    expect(terminada, isTrue);
  });
}

final _datos = FutureProvider<int>((ref) => _cargaDatos.future);
var _cargaDatos = Completer<int>();

class _Espera extends ConsumerStatefulWidget {
  const _Espera(this.alTerminar);
  final VoidCallback alTerminar;
  @override
  ConsumerState<_Espera> createState() => _EsperaState();
}

class _EsperaState extends ConsumerState<_Espera> {
  final _escuchas = <ProviderSubscription<Object?>>[];

  @override
  void initState() {
    super.initState();
    esperarCargas(ref, [_datos], _escuchas).then((_) => widget.alTerminar());
  }

  @override
  void dispose() {
    for (final e in _escuchas) {
      e.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

void mainEspera() {
  testWidgets('si la carga se reinicia, sigue esperando la nueva', (
    tester,
  ) async {
    _cargaDatos = Completer<int>();
    var terminada = false;
    late WidgetRef ref;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, r, _) {
            ref = r;
            return _Espera(() => terminada = true);
          },
        ),
      ),
    );
    await tester.pump();
    expect(terminada, isFalse);

    // Se reinicia antes de terminar (p. ej. al renovar la sesión).
    final primera = _cargaDatos;
    _cargaDatos = Completer<int>();
    ref.invalidate(_datos);
    await tester.pump();
    primera.complete(1);
    await tester.pump();
    expect(terminada, isFalse, reason: 'la carga nueva aún no termina');

    _cargaDatos.complete(2);
    await tester.pump();
    await tester.pump();
    expect(terminada, isTrue);
  });
}
