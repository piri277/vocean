import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/features/cultura/data/contenido_lsc.dart';
import 'package:miapp/features/cultura/views/quiz_cultura.dart';

/// Datos de un tema como flash cards: cada tarjeta muestra el título al
/// frente y se voltea al tocarla para ver la explicación. Al final, el quiz.
class HistoriasTema extends StatefulWidget {
  const HistoriasTema({super.key, required this.tema, this.completado = false});

  final TemaLsc tema;

  /// El quiz ya dio su XP: se ofrece como repaso.
  final bool completado;

  @override
  State<HistoriasTema> createState() => _HistoriasTemaState();
}

class _HistoriasTemaState extends State<HistoriasTema> {
  final _paginas = PageController(viewportFraction: 0.84);
  int _actual = 0;

  /// Una tarjeta por dato más la del quiz.
  int get _total => widget.tema.datos.length + 1;

  @override
  void dispose() {
    _paginas.dispose();
    super.dispose();
  }

  void _ir(int pagina) => _paginas.animateToPage(
    pagina.clamp(0, _total - 1),
    duration: const Duration(milliseconds: 380),
    curve: Curves.easeOutCubic,
  );

  void _abrirQuiz() => Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => QuizCultura(
        temaId: widget.tema.id,
        titulo: 'Quiz: ${widget.tema.titulo}',
        preguntas: widget.tema.quiz,
        completado: widget.completado,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final tema = widget.tema;
    final datos = tema.datos.length;
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Cerrar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: AppTheme.darkTeal,
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTeal,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(tema.icono, color: AppTheme.darkTeal, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tema.titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.darkTeal,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _actual < datos ? '${_actual + 1}/$datos' : 'Quiz',
                      key: ValueKey(_actual),
                      style: const TextStyle(
                        color: AppTheme.tomato,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: (_actual + 1) / _total),
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                  builder: (_, valor, _) => LinearProgressIndicator(
                    value: valor,
                    minHeight: 6,
                    color: AppTheme.darkTeal,
                    backgroundColor: AppTheme.ringBackground,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _paginas,
                itemCount: _total,
                onPageChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() => _actual = i);
                },
                itemBuilder: (context, i) => _EnCarrusel(
                  controller: _paginas,
                  indice: i,
                  child: i < datos
                      ? _FlashCard(
                          dato: tema.datos[i],
                          numero: i + 1,
                          icono: tema.icono,
                        )
                      : _TarjetaQuiz(
                          preguntas: tema.quiz.length,
                          completado: widget.completado,
                          onEmpezar: _abrirQuiz,
                        ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  _BotonRedondo(
                    icono: Icons.arrow_back_rounded,
                    tooltip: 'Anterior',
                    onPressed: _actual > 0 ? () => _ir(_actual - 1) : null,
                  ),
                  Expanded(
                    child: _Puntos(total: _total, actual: _actual),
                  ),
                  _BotonRedondo(
                    icono: Icons.arrow_forward_rounded,
                    tooltip: 'Siguiente',
                    onPressed: _actual < _total - 1
                        ? () => _ir(_actual + 1)
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Achica, inclina y atenúa las tarjetas que no están al centro.
class _EnCarrusel extends StatelessWidget {
  const _EnCarrusel({
    required this.controller,
    required this.indice,
    required this.child,
  });

  final PageController controller;
  final int indice;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final pagina =
            controller.hasClients && controller.position.haveDimensions
            ? controller.page!
            : controller.initialPage.toDouble();
        final d = (indice - pagina).clamp(-1.0, 1.0);
        return Opacity(
          opacity: 1 - 0.45 * d.abs(),
          child: Transform.rotate(
            angle: d * 0.07,
            child: Transform.scale(scale: 1 - 0.1 * d.abs(), child: child),
          ),
        );
      },
    );
  }
}

/// Tarjeta que se voltea en 3D: frente con el título, reverso con el texto.
class _FlashCard extends StatefulWidget {
  const _FlashCard({
    required this.dato,
    required this.numero,
    required this.icono,
  });

  final DatoLsc dato;
  final int numero;
  final IconData icono;

  @override
  State<_FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<_FlashCard>
    with SingleTickerProviderStateMixin {
  late final _giro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  );
  late final _curva = CurvedAnimation(
    parent: _giro,
    curve: Curves.easeInOutBack,
  );

  @override
  void dispose() {
    _giro.dispose();
    super.dispose();
  }

  void _voltear() {
    HapticFeedback.lightImpact();
    _giro.isForwardOrCompleted ? _giro.reverse() : _giro.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Semantics(
        button: true,
        label: 'Voltear tarjeta',
        child: GestureDetector(
          onTap: _voltear,
          child: AnimatedBuilder(
            animation: _curva,
            builder: (context, _) {
              final angulo = _curva.value * pi;
              final reverso = angulo > pi / 2;
              // Se levanta un poco a mitad del giro.
              final elevacion = sin(_giro.value * pi);
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(angulo)
                  ..scaleByDouble(
                    1 + 0.04 * elevacion,
                    1 + 0.04 * elevacion,
                    1,
                    1,
                  ),
                child: reverso
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(pi),
                        child: _Reverso(dato: widget.dato),
                      )
                    : _Frente(
                        dato: widget.dato,
                        numero: widget.numero,
                        icono: widget.icono,
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

BoxDecoration _decoracionTarjeta(Color color) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(30),
  boxShadow: [
    BoxShadow(
      color: AppTheme.darkTeal.withValues(alpha: 0.22),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ],
);

class _Frente extends StatelessWidget {
  const _Frente({
    required this.dato,
    required this.numero,
    required this.icono,
  });

  final DatoLsc dato;
  final int numero;
  final IconData icono;

  @override
  Widget build(BuildContext context) {
    const crema = AppTheme.bgCream;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _decoracionTarjeta(AppTheme.darkTeal),
      child: Stack(
        children: [
          Positioned(
            right: -60,
            top: -60,
            child: _Circulo(200, crema.withValues(alpha: 0.07)),
          ),
          Positioned(
            left: -40,
            bottom: -50,
            child: _Circulo(150, crema.withValues(alpha: 0.05)),
          ),
          Positioned(
            right: 34,
            bottom: 90,
            child: _Circulo(16, AppTheme.tomato.withValues(alpha: 0.9)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 24, 26, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: crema.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'DATO $numero',
                    style: const TextStyle(
                      color: crema,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: crema.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icono, color: crema, size: 36),
                ),
                const SizedBox(height: 20),
                Text(
                  dato.titulo,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: crema,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    height: 1.12,
                  ),
                ),
                const Spacer(),
                const _PistaVoltear(color: crema),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Reverso extends StatelessWidget {
  const _Reverso({required this.dato});

  final DatoLsc dato;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: _decoracionTarjeta(AppTheme.cardBg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 8, color: AppTheme.tomato),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dato.titulo,
                    style: const TextStyle(
                      color: AppTheme.tomato,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    dato.texto,
                    style: const TextStyle(
                      color: AppTheme.darkTeal,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.42,
                    ),
                  ),
                  if (dato.fuente != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTeal,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.menu_book_outlined,
                            size: 16,
                            color: AppTheme.darkTeal,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dato.fuente!,
                              style: const TextStyle(
                                color: AppTheme.darkTeal,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: _PistaVoltear(color: AppTheme.grey, volver: true),
          ),
        ],
      ),
    );
  }
}

/// «Toca para voltear», con un pequeño latido para invitar a tocar.
class _PistaVoltear extends StatefulWidget {
  const _PistaVoltear({required this.color, this.volver = false});

  final Color color;
  final bool volver;

  @override
  State<_PistaVoltear> createState() => _PistaVoltearState();
}

class _PistaVoltearState extends State<_PistaVoltear>
    with SingleTickerProviderStateMixin {
  late final _latido = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _latido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ScaleTransition(
          scale: Tween(
            begin: 0.85,
            end: 1.1,
          ).animate(CurvedAnimation(parent: _latido, curve: Curves.easeInOut)),
          child: Icon(
            widget.volver ? Icons.replay_rounded : Icons.touch_app_outlined,
            color: widget.color,
            size: 20,
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            widget.volver ? 'Toca para volver' : 'Toca para voltear',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: widget.color.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _TarjetaQuiz extends StatelessWidget {
  const _TarjetaQuiz({
    required this.preguntas,
    required this.completado,
    required this.onEmpezar,
  });

  final int preguntas;
  final bool completado;
  final VoidCallback onEmpezar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: _decoracionTarjeta(
          completado ? AppTheme.darkTeal : AppTheme.tomato,
        ),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              top: -50,
              child: _Circulo(180, Colors.white.withValues(alpha: 0.1)),
            ),
            Positioned(
              left: -40,
              bottom: -40,
              child: _Circulo(130, Colors.white.withValues(alpha: 0.08)),
            ),
            Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      completado
                          ? Icons.verified_rounded
                          : Icons.emoji_events_outlined,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    completado ? '¡Tema completado!' : '¿Listo para el quiz?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    completado
                        ? 'Ya ganaste la XP de este tema. Puedes repasar el '
                              'quiz cuando quieras, sin XP.'
                        : '$preguntas preguntas. Acierta el 75 % y gana XP la '
                              'primera vez.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onEmpezar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.tomato,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Empezar quiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Puntos de avance: el actual se alarga.
class _Puntos extends StatelessWidget {
  const _Puntos({required this.total, required this.actual});

  final int total;
  final int actual;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 5,
      runSpacing: 5,
      children: [
        for (var i = 0; i < total; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: i == actual ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == actual
                  ? (i == total - 1 ? AppTheme.tomato : AppTheme.darkTeal)
                  : AppTheme.ringBackground,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

class _BotonRedondo extends StatelessWidget {
  const _BotonRedondo({
    required this.icono,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icono;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icono),
      style: IconButton.styleFrom(
        backgroundColor: AppTheme.darkTeal,
        foregroundColor: AppTheme.bgCream,
        disabledBackgroundColor: AppTheme.ringBackground,
        disabledForegroundColor: AppTheme.grey,
        minimumSize: const Size(52, 52),
      ),
    );
  }
}

class _Circulo extends StatelessWidget {
  const _Circulo(this.tamano, this.color);

  final double tamano;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: tamano,
    height: tamano,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
