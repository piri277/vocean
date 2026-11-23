import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:miapp/core/theme/app_theme.dart';

/// Pantalla de entrada: anima el logo y el nombre mientras la app carga detrás.
///
/// Se queda hasta que termina la animación y [cargando] se resuelve; luego se
/// desvanece y llama a [alTerminar].
class BienvenidaAnimada extends StatefulWidget {
  const BienvenidaAnimada({
    super.key,
    required this.cargando,
    required this.alTerminar,
  });

  final Future<void> cargando;
  final VoidCallback alTerminar;

  @override
  State<BienvenidaAnimada> createState() => _BienvenidaAnimadaState();
}

class _BienvenidaAnimadaState extends State<BienvenidaAnimada>
    with TickerProviderStateMixin {
  static const _nombre = 'VOCEAN';

  late final _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  );
  late final _salida = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  bool _esperando = false;

  @override
  void initState() {
    super.initState();
    _arrancar();
  }

  Future<void> _arrancar() async {
    final carga = _esperarCarga();
    await _entrada.forward();
    if (!mounted) return;
    setState(() => _esperando = true);
    await carga;
    if (!mounted) return;
    await _salida.forward();
    if (mounted) widget.alTerminar();
  }

  /// Espera la carga sin lanzar: si falla o tarda demasiado, la pantalla de
  /// cada pestaña muestra su propio error.
  Future<void> _esperarCarga() async {
    try {
      await widget.cargando;
    } catch (e) {
      debugPrint('La carga inicial falló o tardó demasiado: $e');
    }
  }

  @override
  void dispose() {
    _entrada.dispose();
    _salida.dispose();
    super.dispose();
  }

  Animation<double> _tramo(
    double inicio,
    double fin, [
    Curve curva = Curves.easeOut,
  ]) => CurvedAnimation(
    parent: _entrada,
    curve: Interval(inicio, fin, curve: curva),
  );

  @override
  Widget build(BuildContext context) {
    final logo = _tramo(0, 0.5, Curves.elasticOut);
    final logoOpacidad = _tramo(0, 0.2);
    final lema = _tramo(0.75, 1);

    return AnimatedBuilder(
      animation: Listenable.merge([_entrada, _salida]),
      builder: (context, _) {
        final s = Curves.easeIn.transform(_salida.value);
        return Opacity(
          opacity: 1 - s,
          child: ColoredBox(
            color: AppTheme.darkTeal,
            child: Transform.scale(
              scale: 1 + 0.15 * s,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Opacity(
                      opacity: logoOpacidad.value,
                      child: Transform.scale(
                        scale: 0.4 + 0.6 * logo.value,
                        child: Transform.rotate(
                          angle: (1 - logo.value) * -0.5,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(34),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/branding/icono_app.png',
                              semanticLabel: 'Logo de VOCEAN',
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Cada letra sube y aparece un poco después de la anterior.
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < _nombre.length; i++)
                          _Letra(
                            letra: _nombre[i],
                            avance: _tramo(
                              0.3 + i * 0.06,
                              0.6 + i * 0.06,
                              Curves.easeOutBack,
                            ).value,
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Opacity(
                      opacity: lema.value,
                      child: Transform.translate(
                        offset: Offset(0, 8 * (1 - lema.value)),
                        child: Text(
                          'Aprende Lengua de Señas Colombiana',
                          style: TextStyle(
                            color: AppTheme.bgCream.withValues(alpha: 0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      height: 4,
                      width: 120,
                      child: AnimatedOpacity(
                        opacity: _esperando ? 1 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            color: AppTheme.tomato,
                            backgroundColor: Color(0x33EEE2CB),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Letra extends StatelessWidget {
  const _Letra({required this.letra, required this.avance});

  final String letra;
  final double avance;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: avance.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, 24 * (1 - avance)),
        child: Text(
          letra,
          style: GoogleFonts.poppins(
            color: AppTheme.bgCream,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
          ),
        ),
      ),
    );
  }
}

/// Termina cuando ninguno de los [providers] está cargando. Mira su estado,
/// no un solo Future: si una carga se reinicia, sigue esperando. Las
/// suscripciones quedan en [escuchas] para cerrarlas en `dispose`.
Future<void> esperarCargas(
  WidgetRef ref,
  List<ProviderListenable<AsyncValue<Object?>>> providers,
  List<ProviderSubscription<Object?>> escuchas,
) {
  final listo = Completer<void>();
  void revisar() {
    if (listo.isCompleted) return;
    if (providers.every((p) => !ref.read(p).isLoading)) listo.complete();
  }

  for (final p in providers) {
    escuchas.add(
      ref.listenManual<AsyncValue<Object?>>(
        p,
        (_, _) => revisar(),
        fireImmediately: true,
      ),
    );
  }
  return listo.future;
}
