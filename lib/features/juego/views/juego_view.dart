import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/features/juego/models/dificultad_model.dart';

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
class JuegoView extends StatefulWidget {
  const JuegoView({super.key});

  @override
  State<JuegoView> createState() => _JuegoViewState();
}

class _JuegoViewState extends State<JuegoView> {
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '¿Qué está\ndiciendo?',
                style: TextStyle(
                  color: AppTheme.darkTeal,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _jugando && !terminado
                    ? 'Ronda ${_ronda + 1} de ${_preguntas.length}'
                    : 'Une las señas, descubre la palabra y suma puntos.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: _datos == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.darkTeal,
                        ),
                      )
                    : !_jugando
                    ? _menu()
                    : terminado
                    ? _resultado()
                    : _pregunta(),
              ),
            ],
          ),
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

  Widget _menu() {
    return ListView(
      children: [
        _titulo('Categoría'),
        for (final c in _Categoria.values)
          _OpcionCard(
            emoji: _emojiCategoria[c]!,
            color: _colorCategoria[c]!,
            titulo: _etiquetaCategoria[c]!,
            detalle: _detalleCategoria[c]!,
            seleccionada: _categoria == c,
            onTap: () => setState(() => _categoria = c),
          ),
        const SizedBox(height: 8),
        _titulo('Dificultad'),
        for (final d in Dificultad.values)
          _OpcionCard(
            emoji: _emojiDificultad[d]!,
            color: _colorDificultad[d]!,
            titulo: _etiquetaDificultad[d]!,
            detalle: _detalleDificultad[d]!,
            seleccionada: _dificultad == d,
            onTap: () => setState(() => _dificultad = d),
          ),
        const SizedBox(height: 8),
        _BotonPrincipal(texto: 'Empezar', onPressed: () => setState(_empezar)),
        const SizedBox(height: 8),
      ],
    );
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
            const Text('🏆', style: TextStyle(fontSize: 52)),
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

  Widget _pregunta() {
    final correcta = _preguntas[_ronda];
    final size = correcta.length > 7 ? 48.0 : 64.0;
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
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
        for (final o in _opciones)
          _RespuestaCard(
            texto: o.toUpperCase(),
            estado: _estadoOpcion(o, correcta),
            onTap: () => _elegir(o),
          ),
        if (_elegida != null) ...[
          const SizedBox(height: 4),
          _BotonPrincipal(
            texto: _ronda + 1 < _preguntas.length
                ? 'Siguiente'
                : 'Ver resultado',
            onPressed: _siguiente,
          ),
        ],
      ],
    );
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
  color: Colors.white,
  borderRadius: BorderRadius.circular(28),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ],
);

const _emojiCategoria = {
  _Categoria.palabras: '🔤',
  _Categoria.numeros: '🔢',
  _Categoria.mezcla: '🎲',
};
const _colorCategoria = {
  _Categoria.palabras: AppTheme.lightTeal,
  _Categoria.numeros: Color(0xFFFFF8E1),
  _Categoria.mezcla: Color(0xFFEDE7F6),
};
const _detalleCategoria = {
  _Categoria.palabras: 'Adivina palabras letra por letra',
  _Categoria.numeros: 'Adivina números dígito por dígito',
  _Categoria.mezcla: 'Palabras y números juntos',
};
const _emojiDificultad = {
  Dificultad.facil: '🌱',
  Dificultad.medio: '🌿',
  Dificultad.dificil: '🔥',
  Dificultad.extremo: '⚡',
};
const _colorDificultad = {
  Dificultad.facil: AppTheme.lightTeal,
  Dificultad.medio: Color(0xFFFFF8E1),
  Dificultad.dificil: Color(0xFFFCE4EC),
  Dificultad.extremo: Color(0xFFEDE7F6),
};
const _detalleDificultad = {
  Dificultad.facil: '2 a 3 señas',
  Dificultad.medio: '4 a 5 señas',
  Dificultad.dificil: '6 a 7 señas',
  Dificultad.extremo: '8 o más señas',
};

class _OpcionCard extends StatelessWidget {
  const _OpcionCard({
    required this.emoji,
    required this.color,
    required this.titulo,
    required this.detalle,
    required this.seleccionada,
    required this.onTap,
  });

  final String emoji;
  final Color color;
  final String titulo;
  final String detalle;
  final bool seleccionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(14),
          decoration: _decoracionCard.copyWith(
            border: Border.all(
              color: seleccionada ? AppTheme.buttonTeal : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        color: AppTheme.darkTeal,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detalle,
                      style: const TextStyle(
                        color: AppTheme.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (seleccionada)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.buttonTeal,
                ),
            ],
          ),
        ),
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
        const Color(0xFFFDECEA),
        AppTheme.coral,
        Icons.cancel_rounded,
      ),
      _Estado.apagada => (Colors.white, Colors.transparent, null),
      _Estado.neutra => (Colors.white, Colors.transparent, null),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: _decoracionCard.copyWith(
            color: fondo,
            border: Border.all(color: borde, width: 2),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  texto,
                  style: TextStyle(
                    color: estado == _Estado.apagada
                        ? AppTheme.grey
                        : AppTheme.darkTeal,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (icono != null) Icon(icono, color: borde),
            ],
          ),
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
