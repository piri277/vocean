import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/core/widgets/encabezado_pantalla.dart';
import 'package:miapp/features/juego/models/dificultad_model.dart';
import 'package:miapp/features/perfil/providers/perfil_provider.dart';

const _rondas = 8;

enum _Categoria { palabras, numeros, mezcla }

const _etiquetaCategoria = {
  _Categoria.palabras: 'Palabras',
  _Categoria.numeros: 'Números',
  _Categoria.mezcla: 'Mezcla',
};

const _etiquetaDificultad = {
  Dificultad.facil: 'Fácil',
  Dificultad.medio: 'Medio',
  Dificultad.dificil: 'Difícil',
  Dificultad.extremo: 'Extremo',
};

bool _esNumero(String s) => RegExp(r'\d').hasMatch(s);

/// Juego: adivinar la palabra o número formado por señas estáticas.
class JuegoView extends ConsumerStatefulWidget {
  const JuegoView({super.key});

  @override
  ConsumerState<JuegoView> createState() => _JuegoViewState();
}

class _JuegoViewState extends ConsumerState<JuegoView> {
  final _rnd = Random();
  // categoria -> dificultad -> textos; viene de assets/juego/palabras.json.
  Map<String, Map<String, List<String>>>? _datos;
  _Categoria _categoria = _Categoria.mezcla;
  Dificultad _dificultad = Dificultad.facil;
  bool _jugando = false;
  List<String> _preguntas = [];
  int _ronda = 0;
  int _aciertos = 0;
  List<String> _opciones = [];
  String? _elegida;
  // Mensaje de XP de la partida terminada; null mientras se envía.
  String? _mensajeXp;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/juego/palabras.json').then((txt) {
      final raw = jsonDecode(txt) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _datos = {
          for (final e in raw.entries)
            e.key: {
              for (final n in (e.value as Map<String, dynamic>).entries)
                n.key: List<String>.from(n.value as List),
            },
        };
      });
    });
  }

  List<String> _nivel(String cat) => _datos![cat]![_dificultad.name] ?? [];

  void _empezar() {
    final pool = switch (_categoria) {
      _Categoria.palabras => _nivel('palabras'),
      _Categoria.numeros => _nivel('numeros'),
      _Categoria.mezcla => [..._nivel('palabras'), ..._nivel('numeros')],
    }..shuffle(_rnd);
    _preguntas = pool.take(_rondas).toList();
    _ronda = 0;
    _aciertos = 0;
    _mensajeXp = null;
    _jugando = true;
    _prepararRonda();
  }

  void _prepararRonda() {
    final correcta = _preguntas[_ronda];
    final esNum = _esNumero(correcta);
    final pool = [
      for (final nivel in _datos![esNum ? 'numeros' : 'palabras']!.values)
        ...nivel,
    ].where((p) => p != correcta).toList()..shuffle(_rnd);
    // Los distractores de largo parecido hacen el reto más justo.
    pool.sort(
      (a, b) => (a.length - correcta.length).abs().compareTo(
        (b.length - correcta.length).abs(),
      ),
    );
    _opciones = [correcta, ...pool.take(3)]..shuffle(_rnd);
    _elegida = null;
  }

  void _elegir(String opcion) {
    if (_elegida != null) return;
    setState(() {
      _elegida = opcion;
      if (opcion == _preguntas[_ronda]) _aciertos++;
    });
  }

  void _siguiente() {
    setState(() {
      _ronda++;
      if (_ronda < _preguntas.length) _prepararRonda();
    });
    if (_ronda >= _preguntas.length) _registrarResultado();
  }

  /// Envía el resultado; el backend da XP solo la 1.ª victoria por modo y dificultad.
  Future<void> _registrarResultado() async {
    final antes = ref.read(usuarioFutureProvider).valueOrNull?.xpTotal;
    String mensaje;
    try {
      final usuario = await ref
          .read(usuarioRepositoryProvider)
          .registrarResultadoJuego(
            modo: _categoria.name,
            dificultad: _dificultad.name,
            aciertos: _aciertos,
            total: _preguntas.length,
          );
      ref.invalidate(usuarioFutureProvider);
      final ganada = antes == null ? 0 : usuario.xpTotal - antes;
      final gano = _aciertos >= (_preguntas.length * 0.75).ceil();
      mensaje = ganada > 0
          ? '+$ganada XP'
          : gano
          ? 'Ya ganaste la XP de este modo y dificultad'
          : 'Acierta ${(_preguntas.length * 0.75).ceil()} para ganar XP';
    } catch (e) {
      debugPrint('No se pudo registrar el resultado del juego: $e');
      mensaje = 'No se pudo guardar la XP';
    }
    if (mounted) setState(() => _mensajeXp = mensaje);
  }

  String _asset(String c) => RegExp(r'\d').hasMatch(c)
      ? 'assets/numeros/$c.png'
      : 'assets/letras/$c.png';

  @override
  Widget build(BuildContext context) {
    final terminado = _jugando && _ronda >= _preguntas.length;
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        // Un solo ListView: el encabezado se desplaza con el contenido.
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            EncabezadoPantalla(
              etiqueta: 'Modo juego',
              pildora: PildoraInfo(
                icono: Icons.star_rounded,
                texto: '${ref.watch(usuarioProvider)?.xpTotal ?? 0} XP',
              ),
              titulo: '¿Qué está diciendo?',
              subtitulo: _jugando && !terminado
                  ? 'Ronda ${_ronda + 1} de ${_preguntas.length}'
                  : 'Une las señas, descubre la palabra y suma XP.',
            ),
            const SizedBox(height: 22),
            if (_datos == null)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.darkTeal),
                ),
              )
            else if (!_jugando)
              ..._menu()
            else if (terminado)
              _resultado()
            else
              ..._pregunta(),
          ],
        ),
      ),
    );
  }

  Widget _titulo(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      t,
      style: const TextStyle(
        color: AppTheme.darkTeal,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
  );

  List<Widget> _menu() {
    return [
      _titulo('Elige el modo'),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final c in _Categoria.values) ...[
              if (c != _Categoria.values.first) const SizedBox(width: 10),
              Expanded(
                child: _ModoTile(
                  icono: _iconoCategoria[c]!,
                  titulo: _etiquetaCategoria[c]!,
                  detalle: _detalleCategoria[c]!,
                  seleccionado: _categoria == c,
                  onTap: () => setState(() => _categoria = c),
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 24),
      _titulo('Dificultad'),
      _SelectorDificultad(
        actual: _dificultad,
        onChanged: (d) => setState(() => _dificultad = d),
      ),
      const SizedBox(height: 24),
      _ResumenPartida(
        modo: _etiquetaCategoria[_categoria]!,
        dificultad: _dificultad,
        onEmpezar: () => setState(_empezar),
      ),
    ];
  }

  Widget _resultado() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: _decoracionCard,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              size: 56,
              color: AppTheme.tomato,
            ),
            const SizedBox(height: 8),
            Text(
              '$_aciertos / ${_preguntas.length}',
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: AppTheme.darkTeal,
              ),
            ),
            const Text('Aciertos', style: TextStyle(color: AppTheme.grey)),
            const SizedBox(height: 12),
            Text(
              _mensajeXp ?? 'Guardando…',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: _mensajeXp?.startsWith('+') ?? false
                    ? const Color(0xFFEE4129)
                    : AppTheme.grey,
              ),
            ),
            const SizedBox(height: 24),
            _BotonPrincipal(
              texto: 'Jugar de nuevo',
              onPressed: () => setState(_empezar),
            ),
            TextButton(
              onPressed: () => setState(() => _jugando = false),
              child: const Text(
                'Cambiar modo',
                style: TextStyle(
                  color: AppTheme.buttonTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _pregunta() {
    final correcta = _preguntas[_ronda];
    final size = correcta.length > 7 ? 48.0 : 64.0;
    return [
      Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value:
                    (_ronda + (_elegida == null ? 0 : 1)) / _preguntas.length,
                minHeight: 10,
                backgroundColor: AppTheme.ringBackground,
                color: AppTheme.darkTeal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.check_rounded, size: 18, color: AppTheme.darkTeal),
          Text(
            '$_aciertos',
            style: const TextStyle(
              color: AppTheme.darkTeal,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: _decoracionCard,
        child: Column(
          children: [
            const Text(
              '¿Qué forman estas señas?',
              style: TextStyle(
                color: AppTheme.darkTeal,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in correcta.split(''))
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTeal,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      _asset(c),
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          c.toUpperCase(),
                          style: const TextStyle(color: AppTheme.grey),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
        children: [
          for (final o in _opciones)
            _RespuestaCard(
              texto: o.toUpperCase(),
              estado: _estadoOpcion(o, correcta),
              onTap: () => _elegir(o),
            ),
        ],
      ),
      if (_elegida != null) ...[
        const SizedBox(height: 16),
        _BotonPrincipal(
          texto: _ronda + 1 < _preguntas.length ? 'Siguiente' : 'Ver resultado',
          onPressed: _siguiente,
        ),
      ],
    ];
  }

  _Estado _estadoOpcion(String o, String correcta) {
    if (_elegida == null) return _Estado.neutra;
    if (o == correcta) return _Estado.correcta;
    if (o == _elegida) return _Estado.incorrecta;
    return _Estado.apagada;
  }
}

enum _Estado { neutra, correcta, incorrecta, apagada }

final _decoracionCard = BoxDecoration(
  color: AppTheme.cardBg,
  borderRadius: BorderRadius.circular(28),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);

const _iconoCategoria = {
  _Categoria.palabras: Icons.abc_rounded,
  _Categoria.numeros: Icons.pin_outlined,
  _Categoria.mezcla: Icons.shuffle_rounded,
};
const _detalleCategoria = {
  _Categoria.palabras: 'Adivina palabras letra por letra',
  _Categoria.numeros: 'Adivina números dígito por dígito',
  _Categoria.mezcla: 'Palabras y números juntos',
};
// Barras de señal: más barras, más difícil.
const _iconoDificultad = {
  Dificultad.facil: Icons.signal_cellular_alt_1_bar_rounded,
  Dificultad.medio: Icons.signal_cellular_alt_2_bar_rounded,
  Dificultad.dificil: Icons.signal_cellular_alt_rounded,
  Dificultad.extremo: Icons.bolt_rounded,
};
// Igual que XP_JUEGO en backend/app/core/progreso.py.
const _xpDificultad = {
  Dificultad.facil: 20,
  Dificultad.medio: 30,
  Dificultad.dificil: 40,
  Dificultad.extremo: 50,
};
const _detalleDificultad = {
  Dificultad.facil: '2 a 3 señas',
  Dificultad.medio: '4 a 5 señas',
  Dificultad.dificil: '6 a 7 señas',
  Dificultad.extremo: '8 o más señas',
};

/// Tarjeta cuadrada de un modo; la elegida se rellena de verde abeto.
class _ModoTile extends StatelessWidget {
  const _ModoTile({
    required this.icono,
    required this.titulo,
    required this.detalle,
    required this.seleccionado,
    required this.onTap,
  });

  final IconData icono;
  final String titulo;
  final String detalle;
  final bool seleccionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final frente = seleccionado ? AppTheme.bgCream : AppTheme.darkTeal;
    return Semantics(
      button: true,
      selected: seleccionado,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(12),
          decoration: _decoracionCard.copyWith(
            color: seleccionado ? AppTheme.darkTeal : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(22),
            boxShadow: seleccionado
                ? [
                    BoxShadow(
                      color: AppTheme.darkTeal.withValues(alpha: 0.3),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : _decoracionCard.boxShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? AppTheme.bgCream.withValues(alpha: 0.15)
                          : AppTheme.lightTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icono, color: frente),
                  ),
                  if (seleccionado)
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 20,
                      color: AppTheme.tomato,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  titulo,
                  maxLines: 1,
                  style: TextStyle(
                    color: frente,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detalle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: frente.withValues(alpha: 0.7),
                  fontSize: 11.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barra segmentada de dificultad: la elegida resalta en rojo tomate.
class _SelectorDificultad extends StatelessWidget {
  const _SelectorDificultad({required this.actual, required this.onChanged});

  final Dificultad actual;
  final ValueChanged<Dificultad> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: _decoracionCard.copyWith(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          for (final d in Dificultad.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: d == actual,
                child: GestureDetector(
                  onTap: () => onChanged(d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: d == actual ? AppTheme.tomato : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _iconoDificultad[d],
                          size: 20,
                          color: d == actual ? Colors.white : AppTheme.darkTeal,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _etiquetaDificultad[d]!,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: d == actual
                                ? Colors.white
                                : AppTheme.darkTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Resumen de la partida elegida y botón para empezar.
class _ResumenPartida extends StatelessWidget {
  const _ResumenPartida({
    required this.modo,
    required this.dificultad,
    required this.onEmpezar,
  });

  final String modo;
  final Dificultad dificultad;
  final VoidCallback onEmpezar;

  @override
  Widget build(BuildContext context) {
    Widget dato(IconData icono, String texto) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, size: 16, color: AppTheme.grey),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(color: AppTheme.grey, fontSize: 13)),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _decoracionCard.copyWith(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$modo · ${_etiquetaDificultad[dificultad]}',
            style: const TextStyle(
              color: AppTheme.darkTeal,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              dato(Icons.flag_outlined, '$_rondas rondas'),
              dato(Icons.back_hand_outlined, _detalleDificultad[dificultad]!),
              dato(
                Icons.star_outline_rounded,
                '+${_xpDificultad[dificultad]} XP al ganar',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onEmpezar,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text(
                'Empezar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RespuestaCard extends StatelessWidget {
  const _RespuestaCard({
    required this.texto,
    required this.estado,
    required this.onTap,
  });

  final String texto;
  final _Estado estado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (fondo, borde, icono) = switch (estado) {
      _Estado.correcta => (
        AppTheme.lightTeal,
        AppTheme.buttonTeal,
        Icons.check_circle_rounded,
      ),
      _Estado.incorrecta => (
        const Color(0xFFF8D5CC),
        AppTheme.coral,
        Icons.cancel_rounded,
      ),
      _Estado.apagada => (AppTheme.cardBg, Colors.transparent, null),
      _Estado.neutra => (AppTheme.cardBg, Colors.transparent, null),
    };
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: _decoracionCard.copyWith(
          color: fondo,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borde, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                texto,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: estado == _Estado.apagada
                      ? AppTheme.grey
                      : AppTheme.darkTeal,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (icono != null) ...[
              const SizedBox(width: 6),
              Icon(icono, color: borde, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}

class _BotonPrincipal extends StatelessWidget {
  const _BotonPrincipal({required this.texto, required this.onPressed});

  final String texto;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
