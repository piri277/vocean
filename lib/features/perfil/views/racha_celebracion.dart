import 'package:flutter/material.dart';
import 'package:miapp/core/theme/app_theme.dart';

/// Racha antes y después del primer acierto del día.
typedef SubidaRacha = ({int anterior, int nueva});

/// Muestra la celebración de racha a pantalla completa (fuego + contador).
Future<void> mostrarCelebracionRacha(
  BuildContext context, {
  required int anterior,
  required int nueva,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) =>
        RachaCelebracion(anterior: anterior, nueva: nueva),
    transitionBuilder: (_, anim, _, child) =>
        FadeTransition(opacity: anim, child: child),
  );
}

class RachaCelebracion extends StatefulWidget {
  const RachaCelebracion({
    super.key,
    required this.anterior,
    required this.nueva,
  });

  final int anterior;
  final int nueva;

  @override
  State<RachaCelebracion> createState() => _RachaCelebracionState();
}

class _RachaCelebracionState extends State<RachaCelebracion>
    with TickerProviderStateMixin {
  static const _naranja = Color(0xFFFF9600);

  // Entrada: el fuego crece con rebote, luego el número cambia.
  late final _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  // Latido continuo del fuego.
  late final _latido = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final _escalaFuego = CurvedAnimation(
    parent: _entrada,
    curve: const Interval(0, 0.45, curve: Curves.elasticOut),
  );
  late final _cambioNumero = CurvedAnimation(
    parent: _entrada,
    curve: const Interval(0.45, 0.7, curve: Curves.easeOutBack),
  );
  late final _textos = CurvedAnimation(
    parent: _entrada,
    curve: const Interval(0.65, 1, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _entrada.dispose();
    _latido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dias = widget.nueva == 1 ? 'día' : 'días';
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_escalaFuego, _latido]),
                builder: (_, child) => Transform.scale(
                  scale: _escalaFuego.value * (1 + 0.08 * _latido.value),
                  child: child,
                ),
                child: const Text('🔥', style: TextStyle(fontSize: 96)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 72,
                child: AnimatedBuilder(
                  animation: _cambioNumero,
                  builder: (_, _) => _Contador(
                    anterior: widget.anterior,
                    nueva: widget.nueva,
                    t: _cambioNumero.value,
                    color: _naranja,
                  ),
                ),
              ),
              FadeTransition(
                opacity: _textos,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(_textos),
                  child: Column(
                    children: [
                      Text(
                        '$dias de racha',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _naranja,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.nueva == 1
                            ? '¡Empezaste tu racha! Vuelve mañana para mantenerla.'
                            : '¡Sigue así! Practica mañana para no perderla.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.darkTeal,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Semana(racha: widget.nueva, color: _naranja),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: _naranja,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'CONTINUAR',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// El número viejo sube y se va; el nuevo entra desde abajo.
class _Contador extends StatelessWidget {
  const _Contador({
    required this.anterior,
    required this.nueva,
    required this.t,
    required this.color,
  });

  final int anterior;
  final int nueva;
  final double t;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(
      fontSize: 60,
      fontWeight: FontWeight.w900,
      color: color,
      height: 1,
    );
    return ClipRect(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: Offset(0, -72 * t),
            child: Opacity(
              opacity: (1 - t).clamp(0, 1),
              child: Text('$anterior', style: estilo),
            ),
          ),
          Transform.translate(
            offset: Offset(0, 72 * (1 - t)),
            child: Text('$nueva', style: estilo),
          ),
        ],
      ),
    );
  }
}

/// Semana actual de lunes a domingo: encendidos los días de la racha hasta hoy.
class _Semana extends StatelessWidget {
  const _Semana({required this.racha, required this.color});

  final int racha;
  final Color color;

  static const _letras = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final hoyIndice = DateTime.now().weekday - 1; // 0 = lunes
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final diasAtras = hoyIndice - i;
        final encendido = diasAtras >= 0 && diasAtras < racha;
        return Column(
          children: [
            Text(
              _letras[i],
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: i == hoyIndice ? color : AppTheme.grey,
              ),
            ),
            const SizedBox(height: 6),
            CircleAvatar(
              radius: 15,
              backgroundColor: encendido ? color : AppTheme.ringBackground,
              child: encendido
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ],
        );
      }),
    );
  }
}
