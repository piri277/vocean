import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miapp/core/theme/app_theme.dart';

/// Resultado de una respuesta, para animarla.
enum Respuesta { correcta, incorrecta }

/// Sonidos y vibración de juegos y quizzes (`assets/audio/efectos/`).
abstract final class Sonidos {
  /// En `flutter test` no hay plugin de audio.
  static bool activo = !Platform.environment.containsKey('FLUTTER_TEST');
  static AudioPlayer? _reproductor;

  static Future<void> _tocar(String archivo) async {
    if (!activo) return;
    try {
      final r = _reproductor ??= AudioPlayer();
      await r.stop();
      await r.play(AssetSource('audio/efectos/$archivo.wav'));
    } catch (e) {
      debugPrint('No se pudo tocar el sonido $archivo: $e');
    }
  }

  static void respuesta(Respuesta r) {
    if (r == Respuesta.correcta) {
      HapticFeedback.lightImpact();
      _tocar('acierto');
    } else {
      HapticFeedback.mediumImpact();
      _tocar('error');
    }
  }

  static void finalPartida({required bool gano}) =>
      _tocar(gano ? 'final' : 'final_suave');
}

/// Anima una opción al responder: la correcta salta y suelta chispas; la
/// incorrecta tiembla. Sin [resultado] no hace nada.
class AnimacionRespuesta extends StatefulWidget {
  const AnimacionRespuesta({
    super.key,
    required this.resultado,
    required this.child,
  });

  final Respuesta? resultado;
  final Widget child;

  @override
  State<AnimacionRespuesta> createState() => _AnimacionRespuestaState();
}

class _AnimacionRespuestaState extends State<AnimacionRespuesta>
    with SingleTickerProviderStateMixin {
  late final _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  @override
  void initState() {
    super.initState();
    if (widget.resultado != null) _anim.forward();
  }

  @override
  void didUpdateWidget(AnimacionRespuesta viejo) {
    super.didUpdateWidget(viejo);
    if (widget.resultado != viejo.resultado) {
      widget.resultado == null ? _anim.reset() : _anim.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      child: widget.child,
      builder: (context, child) {
        final t = _anim.value;
        return switch (widget.resultado) {
          null => child!,
          Respuesta.incorrecta => Transform.translate(
            // Tres sacudidas que se apagan.
            offset: Offset(sin(t * pi * 6) * 9 * (1 - t), 0),
            child: child,
          ),
          Respuesta.correcta => Stack(
            // Passthrough: la tarjeta conserva el tamaño de su celda.
            fit: StackFit.passthrough,
            clipBehavior: Clip.none,
            children: [
              Transform.scale(
                scale: 1 + 0.09 * sin(pi * Curves.easeOut.transform(t)),
                child: child,
              ),
              if (_anim.isAnimating)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(painter: _Chispas(t)),
                  ),
                ),
            ],
          ),
        };
      },
    );
  }
}

/// Puntitos que salen del centro de la opción correcta.
class _Chispas extends CustomPainter {
  _Chispas(this.t);

  final double t;
  static const _colores = [
    AppTheme.tomato,
    AppTheme.darkTeal,
    Color(0xFFF2B33D),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final avance = Curves.easeOutCubic.transform(t);
    final alcance = size.shortestSide * 0.5 + 34;
    for (var i = 0; i < 12; i++) {
      final angulo = i / 12 * 2 * pi + 0.3;
      final distancia = alcance * avance * (i.isEven ? 1 : 0.75);
      final p = centro + Offset(cos(angulo), sin(angulo) * 0.7) * distancia;
      canvas.drawCircle(
        p,
        (i.isEven ? 5 : 3.5) * (1 - t),
        Paint()..color = _colores[i % 3].withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(_Chispas viejo) => viejo.t != t;
}

/// Entrada del resultado final: el contenido aparece con rebote, suena la
/// melodía y, si [gano], cae confeti una vez.
class CelebracionFinal extends StatefulWidget {
  const CelebracionFinal({super.key, required this.gano, required this.child});

  final bool gano;
  final Widget child;

  @override
  State<CelebracionFinal> createState() => _CelebracionFinalState();
}

class _CelebracionFinalState extends State<CelebracionFinal>
    with TickerProviderStateMixin {
  late final _entrada = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  late final _confeti = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final _piezas = _Pieza.lluvia(Random());

  @override
  void initState() {
    super.initState();
    Sonidos.finalPartida(gano: widget.gano);
    if (widget.gano) _confeti.forward();
  }

  @override
  void dispose() {
    _entrada.dispose();
    _confeti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final escala = CurvedAnimation(parent: _entrada, curve: Curves.elasticOut);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FadeTransition(
          opacity: CurvedAnimation(parent: _entrada, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween(begin: 0.7, end: 1.0).animate(escala),
            child: widget.child,
          ),
        ),
        if (widget.gano)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confeti,
                builder: (_, _) => _confeti.isAnimating
                    ? CustomPaint(painter: _Confeti(_piezas, _confeti.value))
                    : const SizedBox.shrink(),
              ),
            ),
          ),
      ],
    );
  }
}

class _Pieza {
  _Pieza(
    this.x,
    this.retraso,
    this.velocidad,
    this.giro,
    this.color,
    this.ancho,
  );

  final double x, retraso, velocidad, giro, ancho;
  final Color color;

  static const _colores = [
    AppTheme.tomato,
    AppTheme.darkTeal,
    Color(0xFFF2B33D),
    Color(0xFF7FB89A),
  ];

  static List<_Pieza> lluvia(Random r) => [
    for (var i = 0; i < 46; i++)
      _Pieza(
        r.nextDouble(),
        r.nextDouble() * 0.35,
        0.8 + r.nextDouble() * 0.6,
        (r.nextDouble() - 0.5) * 14,
        _colores[i % _colores.length],
        6 + r.nextDouble() * 5,
      ),
  ];
}

class _Confeti extends CustomPainter {
  _Confeti(this.piezas, this.t);

  final List<_Pieza> piezas;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final alto = size.height + 120;
    for (final p in piezas) {
      final avance = ((t - p.retraso) / (1 - p.retraso)).clamp(0.0, 1.0);
      if (avance <= 0) continue;
      final y = -40 + alto * avance * p.velocidad;
      final x = p.x * size.width + sin(avance * 8 + p.giro) * 14;
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(avance * p.giro);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: p.ancho,
            height: p.ancho * 0.55,
          ),
          const Radius.circular(2),
        ),
        Paint()
          ..color = p.color.withValues(
            alpha: avance > 0.8 ? (1 - avance) * 5 : 1,
          ),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Confeti viejo) => viejo.t != t;
}
