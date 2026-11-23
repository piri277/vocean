import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/core/widgets/retroalimentacion.dart';
import 'package:miapp/features/cultura/data/contenido_lsc.dart';
import 'package:miapp/features/perfil/providers/perfil_provider.dart';

/// Quiz de un tema de Cultura (o de «Mitos y realidades»).
///
/// Al aprobar con el 75 % el backend da XP, solo la primera vez por [temaId].
class QuizCultura extends ConsumerStatefulWidget {
  const QuizCultura({
    super.key,
    required this.temaId,
    required this.titulo,
    required this.preguntas,
    this.cantidad,
    this.mezclarOpciones = true,
    this.completado = false,
  });

  final String temaId;
  final String titulo;
  final List<PreguntaCultura> preguntas;

  /// Cuántas preguntas al azar hacer; todas si es null.
  final int? cantidad;

  /// Las opciones se escriben con la correcta primero: se mezclan al mostrar.
  /// Verdadero/Falso conserva su orden.
  final bool mezclarOpciones;

  /// El tema ya dio su XP: se juega como repaso y no se envía al backend.
  final bool completado;

  @override
  ConsumerState<QuizCultura> createState() => _QuizCulturaState();
}

class _QuizCulturaState extends ConsumerState<QuizCultura> {
  final _azar = Random();
  late List<PreguntaCultura> _preguntas;
  late List<List<int>> _orden;
  int _actual = 0;
  int _aciertos = 0;
  int? _elegida;
  String? _mensajeXp;

  int get _paraAprobar => (_preguntas.length * 0.75).ceil();

  @override
  void initState() {
    super.initState();
    _empezar();
  }

  void _empezar() {
    _preguntas = [...widget.preguntas]..shuffle(_azar);
    if (widget.cantidad != null) {
      _preguntas = _preguntas.take(widget.cantidad!).toList();
    }
    _orden = [
      for (final p in _preguntas)
        [for (var i = 0; i < p.opciones.length; i++) i],
    ];
    if (widget.mezclarOpciones) {
      for (final o in _orden) {
        o.shuffle(_azar);
      }
    }
    _actual = 0;
    _aciertos = 0;
    _elegida = null;
    _mensajeXp = null;
  }

  void _responder(int opcion) {
    if (_elegida != null) return;
    Sonidos.respuesta(
      opcion == _preguntas[_actual].correcta
          ? Respuesta.correcta
          : Respuesta.incorrecta,
    );
    setState(() {
      _elegida = opcion;
      if (opcion == _preguntas[_actual].correcta) _aciertos++;
    });
  }

  void _siguiente() {
    setState(() {
      _actual++;
      _elegida = null;
    });
    if (_actual >= _preguntas.length) _registrar();
  }

  Future<void> _registrar() async {
    if (widget.completado) {
      setState(() => _mensajeXp = 'Repaso: la XP de este tema ya es tuya');
      return;
    }
    String mensaje;
    try {
      // XP de antes, para mostrar cuánta se ganó.
      final antes = (await ref.read(usuarioFutureProvider.future)).xpTotal;
      final usuario = await ref
          .read(usuarioRepositoryProvider)
          .registrarQuizCultura(
            tema: widget.temaId,
            aciertos: _aciertos,
            total: _preguntas.length,
          );
      ref.invalidate(usuarioFutureProvider);
      final ganada = usuario.xpTotal - antes;
      mensaje = ganada > 0
          ? '+$ganada XP'
          : _aciertos >= _paraAprobar
          ? 'Ya ganaste la XP de este tema'
          : 'Acierta $_paraAprobar para ganar XP';
    } catch (e) {
      debugPrint('No se pudo registrar el quiz de ${widget.temaId}: $e');
      mensaje = 'No se pudo guardar la XP';
    }
    if (mounted) setState(() => _mensajeXp = mensaje);
  }

  @override
  Widget build(BuildContext context) {
    final terminado = _actual >= _preguntas.length;
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        foregroundColor: AppTheme.darkTeal,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.titulo,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: SafeArea(child: terminado ? _resultado() : _pregunta()),
    );
  }

  Widget _pregunta() {
    final p = _preguntas[_actual];
    final respondida = _elegida != null;
    final acerto = _elegida == p.correcta;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      children: [
        if (widget.completado) ...[
          const _AvisoRepaso(),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                'Pregunta ${_actual + 1} de ${_preguntas.length}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_aciertos aciertos',
              style: const TextStyle(
                color: AppTheme.tomato,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (_actual + (respondida ? 1 : 0)) / _preguntas.length,
            minHeight: 8,
            color: AppTheme.darkTeal,
            backgroundColor: AppTheme.ringBackground,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.darkTeal,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            p.enunciado,
            style: const TextStyle(
              color: AppTheme.bgCream,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 18),
        for (final i in _orden[_actual])
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _Opcion(
              texto: p.opciones[i],
              estado: !respondida
                  ? _EstadoOpcion.normal
                  : i == p.correcta
                  ? _EstadoOpcion.correcta
                  : i == _elegida
                  ? _EstadoOpcion.incorrecta
                  : _EstadoOpcion.apagada,
              onTap: () => _responder(i),
            ),
          ),
        if (respondida) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  acerto ? Icons.check_circle_rounded : Icons.info_rounded,
                  color: acerto ? AppTheme.darkTeal : AppTheme.tomato,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        acerto ? '¡Correcto!' : 'No exactamente',
                        style: TextStyle(
                          color: acerto ? AppTheme.darkTeal : AppTheme.tomato,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.explicacion,
                        style: const TextStyle(
                          color: AppTheme.darkTeal,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _siguiente,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              _actual == _preguntas.length - 1 ? 'Ver resultado' : 'Siguiente',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ],
    );
  }

  Widget _resultado() {
    final aprobo = _aciertos >= _paraAprobar;
    return CelebracionFinal(
      gano: aprobo,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: aprobo
                    ? AppTheme.lightTeal
                    : AppTheme.tomato.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                aprobo ? Icons.emoji_events_outlined : Icons.refresh_rounded,
                size: 48,
                color: aprobo ? AppTheme.darkTeal : AppTheme.tomato,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            aprobo ? '¡Muy bien!' : 'Casi lo logras',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.darkTeal,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$_aciertos de ${_preguntas.length} correctas',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.grey, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.tomato,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _mensajeXp == null
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _mensajeXp!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: () => setState(_empezar),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text(
              'Intentar de nuevo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.darkTeal,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Volver a Cultura',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

enum _EstadoOpcion { normal, correcta, incorrecta, apagada }

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.texto,
    required this.estado,
    required this.onTap,
  });

  final String texto;
  final _EstadoOpcion estado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (fondo, color, icono) = switch (estado) {
      _EstadoOpcion.normal => (AppTheme.cardBg, AppTheme.darkTeal, null),
      _EstadoOpcion.correcta => (
        AppTheme.darkTeal,
        Colors.white,
        Icons.check_rounded,
      ),
      _EstadoOpcion.incorrecta => (
        AppTheme.tomato,
        Colors.white,
        Icons.close_rounded,
      ),
      _EstadoOpcion.apagada => (
        AppTheme.cardBg.withValues(alpha: 0.6),
        AppTheme.grey,
        null,
      ),
    };
    return AnimacionRespuesta(
      resultado: switch (estado) {
        _EstadoOpcion.correcta => Respuesta.correcta,
        _EstadoOpcion.incorrecta => Respuesta.incorrecta,
        _ => null,
      },
      child: Material(
        color: fondo,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: estado == _EstadoOpcion.normal ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    texto,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (icono != null) Icon(icono, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Aviso de que el quiz ya se aprobó y ahora no da XP.
class _AvisoRepaso extends StatelessWidget {
  const _AvisoRepaso();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.lightTeal,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_rounded, color: AppTheme.darkTeal, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Tema completado. Este repaso ya no da XP.',
              style: TextStyle(
                color: AppTheme.darkTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
