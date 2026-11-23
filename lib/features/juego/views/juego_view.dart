import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/core/widgets/encabezado_pantalla.dart';
import 'package:miapp/core/widgets/retroalimentacion.dart';
import 'package:miapp/features/juego/logic/banco_juego.dart';
import 'package:miapp/features/juego/models/dificultad_model.dart';
import 'package:miapp/features/perfil/providers/perfil_provider.dart';
import 'package:miapp/features/perfil/views/racha_celebracion.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/providers/senas_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _rondas = 8;
const _vidasIniciales = 3;
// Igual que XP_RETO en backend/app/core/progreso.py.
const _xpReto = 25;
// Récord que versiones anteriores guardaban en el teléfono; se sube al perfil.
const _claveRecordLocal = 'record_supervivencia';

/// Tipo de partida.
enum _Tipo { clasico, supervivencia, reto }

const _etiquetaCategoria = {
  CategoriaJuego.palabras: 'Palabras',
  CategoriaJuego.numeros: 'Números',
  CategoriaJuego.mezcla: 'Mezcla',
};

const _etiquetaDificultad = {
  Dificultad.facil: 'Fácil',
  Dificultad.medio: 'Medio',
  Dificultad.dificil: 'Difícil',
  Dificultad.extremo: 'Extremo',
};

String _asset(String c) =>
    esNumero(c) ? 'assets/numeros/$c.png' : 'assets/letras/$c.png';

/// Juego con señas estáticas: adivinar la palabra (o, en modo inverso,
/// elegir las señas de una palabra). Clásico, supervivencia y reto diario.
class JuegoView extends ConsumerStatefulWidget {
  const JuegoView({super.key});

  @override
  ConsumerState<JuegoView> createState() => _JuegoViewState();
}

class _JuegoViewState extends ConsumerState<JuegoView> {
  final _rnd = Random();
  BancoJuego? _banco;

  // Menú.
  _Tipo _tipo = _Tipo.clasico;
  CategoriaJuego _categoria = CategoriaJuego.mezcla;
  Dificultad _dificultad = Dificultad.facil;
  bool _inverso = false;
  bool _repaso = true;

  // Partida.
  bool _jugando = false;
  bool _terminado = false;
  List<PreguntaJuego> _preguntas = [];
  final _usadas = <String>{};
  int _ronda = 0;
  int _aciertos = 0;
  int _vidas = _vidasIniciales;
  String? _elegida;
  bool _nuevoRecord = false;
  // Mensaje de XP de la partida terminada; null mientras se envía.
  String? _mensajeXp;

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/juego/palabras.json').then((txt) {
      final raw = jsonDecode(txt) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _banco = BancoJuego({
          for (final e in raw.entries)
            e.key: {
              for (final n in (e.value as Map<String, dynamic>).entries)
                n.key: List<String>.from(n.value as List),
            },
        });
      });
    });
    _subirRecordLocal();
  }

  /// Récord del perfil (backend).
  int get _record => ref.read(usuarioProvider)?.recordSupervivencia ?? 0;

  /// Sube una sola vez el récord que quedó guardado en el teléfono.
  Future<void> _subirRecordLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final local = prefs.getInt(_claveRecordLocal) ?? 0;
      if (local <= 0) return;
      await ref.read(usuarioRepositoryProvider).registrarSupervivencia(local);
      await prefs.remove(_claveRecordLocal);
      ref.invalidate(usuarioFutureProvider);
    } catch (e) {
      debugPrint('No se pudo subir el récord local: $e');
    }
  }

  /// Repaso inteligente: más peso a los textos con señas en práctica o que
  /// necesitan repaso.
  double Function(String)? _peso() {
    if (!_repaso) return null;
    final estados = {
      for (final s in ref.read(senasProvider)) s.id: s.estadoAprendizaje,
    };
    return (texto) {
      var peso = 1.0;
      for (final c in texto.split('')) {
        peso += switch (estados[esNumero(c) ? 'num-$c' : 'alfa-$c']) {
          NecesitaRepaso() => 3,
          EnPractica() => 2,
          _ => 0,
        };
      }
      return peso;
    };
  }

  bool _retoHecho() =>
      ref
          .read(usuarioProvider)
          ?.juegosGanados
          .contains(claveReto(DateTime.now())) ??
      false;

  void _empezar() {
    final banco = _banco!;
    _ronda = 0;
    _aciertos = 0;
    _vidas = _vidasIniciales;
    _usadas.clear();
    _elegida = null;
    _mensajeXp = null;
    _nuevoRecord = false;
    _terminado = false;
    _preguntas = switch (_tipo) {
      _Tipo.clasico => banco.partida(
        categoria: _categoria,
        dificultad: _dificultad,
        rondas: _rondas,
        rnd: _rnd,
        inversa: _inverso,
        peso: _peso(),
      ),
      _Tipo.supervivencia => [_nuevaSupervivencia()],
      _Tipo.reto => banco.retoDiario(DateTime.now()),
    };
    _jugando = true;
  }

  PreguntaJuego _nuevaSupervivencia() {
    final p = _banco!.preguntaSupervivencia(
      categoria: _categoria,
      aciertos: _aciertos,
      usadas: _usadas,
      rnd: _rnd,
      inversa: _inverso,
      peso: _peso(),
    );
    _usadas.add(p.respuesta);
    return p;
  }

  void _elegir(String opcion) {
    if (_elegida != null) return;
    Sonidos.respuesta(
      opcion == _preguntas[_ronda].respuesta
          ? Respuesta.correcta
          : Respuesta.incorrecta,
    );
    setState(() {
      _elegida = opcion;
      if (opcion == _preguntas[_ronda].respuesta) {
        _aciertos++;
      } else if (_tipo == _Tipo.supervivencia) {
        _vidas--;
      }
    });
  }

  void _siguiente() {
    final fin = _tipo == _Tipo.supervivencia
        ? _vidas <= 0
        : _ronda + 1 >= _preguntas.length;
    setState(() {
      if (fin) {
        _terminado = true;
        return;
      }
      if (_tipo == _Tipo.supervivencia) _preguntas.add(_nuevaSupervivencia());
      _ronda++;
      _elegida = null;
    });
    if (fin) {
      switch (_tipo) {
        case _Tipo.clasico:
          _registrarClasico();
        case _Tipo.supervivencia:
          _registrarSupervivencia();
        case _Tipo.reto:
          _registrarReto();
      }
    }
  }

  /// El backend da XP solo la 1.ª victoria por modo, dificultad y dirección.
  Future<void> _registrarClasico() async {
    final antes = ref.read(usuarioFutureProvider).valueOrNull?.xpTotal;
    final paraGanar = (_preguntas.length * 0.75).ceil();
    String mensaje;
    try {
      final usuario = await ref
          .read(usuarioRepositoryProvider)
          .registrarResultadoJuego(
            modo: _categoria.name,
            dificultad: _dificultad.name,
            inverso: _inverso,
            aciertos: _aciertos,
            total: _preguntas.length,
          );
      ref.invalidate(usuarioFutureProvider);
      final ganada = antes == null ? 0 : usuario.xpTotal - antes;
      mensaje = ganada > 0
          ? '+$ganada XP'
          : _aciertos >= paraGanar
          ? 'Ya ganaste la XP de este modo y dificultad'
          : 'Acierta $paraGanar para ganar XP';
    } catch (e) {
      debugPrint('No se pudo registrar el resultado del juego: $e');
      mensaje = 'No se pudo guardar la XP';
    }
    if (mounted) setState(() => _mensajeXp = mensaje);
  }

  /// El backend guarda el récord del perfil si esta partida lo supera.
  Future<void> _registrarSupervivencia() async {
    final anterior = (await _recordActual()) ?? _record;
    String mensaje;
    var nuevo = false;
    try {
      final usuario = await ref
          .read(usuarioRepositoryProvider)
          .registrarSupervivencia(_aciertos);
      ref.invalidate(usuarioFutureProvider);
      nuevo = usuario.recordSupervivencia > anterior;
      mensaje = nuevo
          ? '¡Nuevo récord!'
          : 'Tu récord: ${usuario.recordSupervivencia}';
    } catch (e) {
      debugPrint('No se pudo guardar el récord: $e');
      mensaje = 'No se pudo guardar el récord';
    }
    if (!mounted) return;
    setState(() {
      _nuevoRecord = nuevo;
      _mensajeXp = mensaje;
    });
  }

  Future<int?> _recordActual() async {
    try {
      return (await ref.read(usuarioFutureProvider.future)).recordSupervivencia;
    } catch (_) {
      return null;
    }
  }

  /// Una partida por día: suma a la racha si hubo aciertos y da XP si se ganó.
  Future<void> _registrarReto() async {
    final hoy = DateTime.now();
    final antes = ref.read(usuarioFutureProvider).valueOrNull;
    final paraGanar = (_preguntas.length * 0.75).ceil();
    String mensaje;
    SubidaRacha? subida;
    try {
      final usuario = await ref
          .read(usuarioRepositoryProvider)
          .registrarRetoDiario(
            fecha: hoy,
            aciertos: _aciertos,
            total: _preguntas.length,
          );
      ref
        ..invalidate(usuarioFutureProvider)
        ..invalidate(diasPracticaProvider);
      final ganada = antes == null ? 0 : usuario.xpTotal - antes.xpTotal;
      mensaje = ganada > 0
          ? '+$ganada XP · ¡Reto superado!'
          : _aciertos >= paraGanar
          ? '¡Reto superado!'
          : 'Necesitabas $paraGanar. Vuelve mañana por otro reto.';
      final anterior = antes?.rachaVigente(hoy) ?? 0;
      final nueva = usuario.rachaVigente(hoy);
      if (nueva > anterior) subida = (anterior: anterior, nueva: nueva);
    } catch (e) {
      debugPrint('No se pudo registrar el reto diario: $e');
      mensaje = 'No se pudo guardar el reto';
    }
    if (!mounted) return;
    setState(() => _mensajeXp = mensaje);
    if (subida != null) {
      mostrarCelebracionRacha(
        context,
        anterior: subida.anterior,
        nueva: subida.nueva,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioProvider);
    final enRonda = _jugando && !_terminado;
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        // Un solo ListView: el encabezado se desplaza con el contenido.
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            EncabezadoPantalla(
              etiqueta: enRonda ? _nombreTipo : 'Modo juego',
              pildora: PildoraInfo(
                icono: Icons.star_rounded,
                texto: '${usuario?.xpTotal ?? 0} XP',
              ),
              titulo: enRonda && _preguntas[_ronda].inversa
                  ? '¿Cuál es la seña?'
                  : '¿Qué está diciendo?',
              subtitulo: !enRonda
                  ? 'Une las señas, descubre la palabra y suma XP.'
                  : _tipo == _Tipo.supervivencia
                  ? 'Llevas $_aciertos aciertos · récord $_record'
                  : 'Ronda ${_ronda + 1} de ${_preguntas.length}',
            ),
            const SizedBox(height: 22),
            if (_banco == null)
              const Padding(
                padding: EdgeInsets.only(top: 40),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.darkTeal),
                ),
              )
            else if (!_jugando)
              ..._menu()
            else if (_terminado)
              _resultado()
            else
              ..._pregunta(),
          ],
        ),
      ),
    );
  }

  String get _nombreTipo => switch (_tipo) {
    _Tipo.clasico => 'Clásico',
    _Tipo.supervivencia => 'Supervivencia',
    _Tipo.reto => 'Reto diario',
  };

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
    final retoHecho = _retoHecho();
    Widget fila(List<Widget> hijos) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, h) in hijos.indexed) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: h),
          ],
        ],
      ),
    );
    return [
      _titulo('Elige el juego'),
      fila([
        _ModoTile(
          icono: Icons.flag_outlined,
          titulo: 'Clásico',
          detalle: '$_rondas rondas, elige dificultad',
          seleccionado: _tipo == _Tipo.clasico,
          onTap: () => setState(() => _tipo = _Tipo.clasico),
        ),
        _ModoTile(
          icono: Icons.favorite_border_rounded,
          titulo: 'Supervivencia',
          detalle: '$_vidasIniciales vidas · récord $_record',
          seleccionado: _tipo == _Tipo.supervivencia,
          onTap: () => setState(() => _tipo = _Tipo.supervivencia),
        ),
        _ModoTile(
          icono: retoHecho
              ? Icons.event_available_rounded
              : Icons.today_rounded,
          titulo: 'Reto diario',
          detalle: retoHecho ? 'Hecho hoy' : '$preguntasReto preguntas',
          seleccionado: _tipo == _Tipo.reto,
          onTap: () => setState(() => _tipo = _Tipo.reto),
        ),
      ]),
      const SizedBox(height: 24),
      if (_tipo == _Tipo.reto)
        _ResumenPartida(
          titulo: retoHecho ? 'Ya jugaste el reto de hoy' : 'Reto de hoy',
          datos: [
            (Icons.public_rounded, 'Las mismas preguntas para todos'),
            (Icons.local_fire_department_outlined, 'Cuenta para tu racha'),
            (Icons.star_outline_rounded, '+$_xpReto XP al ganar'),
          ],
          boton: retoHecho ? 'Vuelve mañana' : 'Jugar el reto',
          onEmpezar: retoHecho ? null : () => setState(_empezar),
        )
      else ...[
        _titulo('Modo'),
        fila([
          for (final c in CategoriaJuego.values)
            _ModoTile(
              icono: _iconoCategoria[c]!,
              titulo: _etiquetaCategoria[c]!,
              detalle: _detalleCategoria[c]!,
              seleccionado: _categoria == c,
              onTap: () => setState(() => _categoria = c),
            ),
        ]),
        const SizedBox(height: 24),
        _titulo('Cómo se juega'),
        _SelectorDireccion(
          inverso: _inverso,
          onChanged: (v) => setState(() => _inverso = v),
        ),
        if (_tipo == _Tipo.clasico) ...[
          const SizedBox(height: 24),
          _titulo('Dificultad'),
          _SelectorDificultad(
            actual: _dificultad,
            onChanged: (d) => setState(() => _dificultad = d),
          ),
        ],
        const SizedBox(height: 16),
        _InterruptorRepaso(
          activo: _repaso,
          onChanged: (v) => setState(() => _repaso = v),
        ),
        const SizedBox(height: 24),
        if (_tipo == _Tipo.clasico)
          _ResumenPartida(
            titulo:
                '${_etiquetaCategoria[_categoria]} · '
                '${_etiquetaDificultad[_dificultad]}',
            datos: [
              (Icons.flag_outlined, '$_rondas rondas'),
              (Icons.back_hand_outlined, _detalleDificultad[_dificultad]!),
              (
                Icons.star_outline_rounded,
                '+${_xpDificultad[_dificultad]} XP al ganar',
              ),
            ],
            boton: 'Empezar',
            onEmpezar: () => setState(_empezar),
          )
        else
          _ResumenPartida(
            titulo: 'Supervivencia · ${_etiquetaCategoria[_categoria]}',
            datos: [
              (Icons.favorite_border_rounded, '$_vidasIniciales vidas'),
              (Icons.trending_up_rounded, 'Sube de nivel cada 5 aciertos'),
              (Icons.emoji_events_outlined, 'Récord: $_record'),
            ],
            boton: 'Empezar',
            onEmpezar: () => setState(_empezar),
          ),
      ],
    ];
  }

  Widget _resultado() {
    final (icono, grande, pie) = switch (_tipo) {
      _Tipo.supervivencia => (
        _nuevoRecord
            ? Icons.workspace_premium_outlined
            : Icons.heart_broken_outlined,
        '$_aciertos',
        'Aciertos antes de perder las 3 vidas',
      ),
      _ => (
        Icons.emoji_events_outlined,
        '$_aciertos / ${_preguntas.length}',
        'Aciertos',
      ),
    };
    final gano = _tipo == _Tipo.supervivencia
        ? _aciertos >= 5
        : _aciertos >= (_preguntas.length * 0.75).ceil();
    return CelebracionFinal(
      gano: gano,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: _decoracionCard,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 56, color: AppTheme.tomato),
            const SizedBox(height: 8),
            Text(
              grande,
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: AppTheme.darkTeal,
              ),
            ),
            Text(
              pie,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.grey),
            ),
            const SizedBox(height: 12),
            Text(
              _mensajeXp ?? 'Guardando…',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: (_mensajeXp?.startsWith('+') ?? false) || _nuevoRecord
                    ? AppTheme.tomato
                    : AppTheme.grey,
              ),
            ),
            const SizedBox(height: 24),
            if (_tipo != _Tipo.reto)
              _BotonPrincipal(
                texto: 'Jugar de nuevo',
                onPressed: () => setState(_empezar),
              ),
            TextButton(
              onPressed: () => setState(() => _jugando = false),
              child: Text(
                _tipo == _Tipo.reto ? 'Volver al menú' : 'Cambiar modo',
                style: const TextStyle(
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
    final p = _preguntas[_ronda];
    return [
      if (_tipo == _Tipo.supervivencia)
        _Vidas(vidas: _vidas, aciertos: _aciertos)
      else
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
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _decoracionCard,
        child: Column(
          children: [
            Text(
              p.inversa ? 'Elige las señas de' : '¿Qué forman estas señas?',
              style: const TextStyle(
                color: AppTheme.darkTeal,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            if (p.inversa)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  p.respuesta.toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.tomato,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
              )
            else
              _TiraSenas(
                texto: p.respuesta,
                tamano: p.respuesta.length > 7 ? 48 : 64,
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      if (p.inversa)
        for (final o in p.opciones)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _OpcionSenas(
              key: ValueKey('opcion-senas-$o'),
              texto: o,
              estado: _estadoOpcion(o, p.respuesta),
              onTap: () => _elegir(o),
            ),
          )
      else
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            for (final o in p.opciones)
              _RespuestaCard(
                texto: o.toUpperCase(),
                estado: _estadoOpcion(o, p.respuesta),
                onTap: () => _elegir(o),
              ),
          ],
        ),
      if (_elegida != null) ...[
        const SizedBox(height: 16),
        _BotonPrincipal(
          texto: switch (_tipo) {
            _Tipo.supervivencia when _vidas <= 0 => 'Ver resultado',
            _Tipo.supervivencia => 'Siguiente',
            _ when _ronda + 1 >= _preguntas.length => 'Ver resultado',
            _ => 'Siguiente',
          },
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

/// Las señas de un texto, una imagen por letra o dígito.
class _TiraSenas extends StatelessWidget {
  const _TiraSenas({required this.texto, required this.tamano});

  final String texto;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: tamano / 8,
      runSpacing: tamano / 8,
      children: [
        for (final c in texto.split(''))
          Container(
            width: tamano,
            height: tamano,
            decoration: BoxDecoration(
              color: AppTheme.lightTeal,
              borderRadius: BorderRadius.circular(tamano / 4),
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
    );
  }
}

/// Opción del modo inverso: una secuencia de señas que se puede tocar.
class _OpcionSenas extends StatelessWidget {
  const _OpcionSenas({
    super.key,
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
      _ => (AppTheme.cardBg, Colors.transparent, null),
    };
    final tamano = texto.length <= 4
        ? 46.0
        : texto.length <= 6
        ? 38.0
        : 30.0;
    return AnimacionRespuesta(
      resultado: _animacion(estado),
      child: Semantics(
        button: true,
        // En el modo inverso la respuesta no se lee: solo se ven las señas.
        label: 'Opción de señas',
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 160),
            opacity: estado == _Estado.apagada ? 0.45 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.all(12),
              decoration: _decoracionCard.copyWith(
                color: fondo,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borde, width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _TiraSenas(texto: texto, tamano: tamano),
                  ),
                  if (icono != null) ...[
                    const SizedBox(width: 8),
                    Icon(icono, color: borde),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Corazones de supervivencia y aciertos.
class _Vidas extends StatelessWidget {
  const _Vidas({required this.vidas, required this.aciertos});

  final int vidas;
  final int aciertos;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _vidasIniciales; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: AnimatedScale(
              scale: i < vidas ? 1 : 0.8,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Icon(
                i < vidas
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: i < vidas ? AppTheme.tomato : AppTheme.ringBackground,
                size: 28,
              ),
            ),
          ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.darkTeal,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            'Nivel ${_etiquetaDificultad[BancoJuego.dificultadSupervivencia(aciertos)]}',
            style: const TextStyle(
              color: AppTheme.bgCream,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

/// Elegir si se ven las señas (adivinar la palabra) o la palabra (elegir señas).
class _SelectorDireccion extends StatelessWidget {
  const _SelectorDireccion({required this.inverso, required this.onChanged});

  final bool inverso;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget opcion(bool valor, IconData icono, String titulo, String detalle) {
      final activo = inverso == valor;
      return Expanded(
        child: Semantics(
          button: true,
          selected: activo,
          child: GestureDetector(
            onTap: () => onChanged(valor),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: activo ? AppTheme.tomato : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(icono, color: activo ? Colors.white : AppTheme.darkTeal),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      titulo,
                      maxLines: 1,
                      style: TextStyle(
                        color: activo ? Colors.white : AppTheme.darkTeal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    detalle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: (activo ? Colors.white : AppTheme.darkTeal)
                          .withValues(alpha: 0.75),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: _decoracionCard.copyWith(
        borderRadius: BorderRadius.circular(22),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            opcion(
              false,
              Icons.back_hand_outlined,
              'Señas → Palabra',
              'Mira las señas y adivina',
            ),
            const SizedBox(width: 6),
            opcion(
              true,
              Icons.text_fields_rounded,
              'Palabra → Señas',
              'Lee y elige las señas',
            ),
          ],
        ),
      ),
    );
  }
}

/// Activa el repaso inteligente.
class _InterruptorRepaso extends StatelessWidget {
  const _InterruptorRepaso({required this.activo, required this.onChanged});

  final bool activo;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardBg,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        value: activo,
        onChanged: onChanged,
        activeThumbColor: AppTheme.bgCream,
        activeTrackColor: AppTheme.darkTeal,
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.lightTeal,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.psychology_outlined,
            color: AppTheme.darkTeal,
          ),
        ),
        title: const Text(
          'Repaso inteligente',
          style: TextStyle(
            color: AppTheme.darkTeal,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: const Text(
          'Salen más las señas que estás practicando o debes repasar',
          style: TextStyle(color: AppTheme.grey, fontSize: 12.5),
        ),
      ),
    );
  }
}

enum _Estado { neutra, correcta, incorrecta, apagada }

Respuesta? _animacion(_Estado e) => switch (e) {
  _Estado.correcta => Respuesta.correcta,
  _Estado.incorrecta => Respuesta.incorrecta,
  _ => null,
};

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
  CategoriaJuego.palabras: Icons.abc_rounded,
  CategoriaJuego.numeros: Icons.pin_outlined,
  CategoriaJuego.mezcla: Icons.shuffle_rounded,
};
const _detalleCategoria = {
  CategoriaJuego.palabras: 'Adivina palabras letra por letra',
  CategoriaJuego.numeros: 'Adivina números dígito por dígito',
  CategoriaJuego.mezcla: 'Palabras y números juntos',
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
    required this.titulo,
    required this.datos,
    required this.boton,
    required this.onEmpezar,
  });

  final String titulo;
  final List<(IconData, String)> datos;
  final String boton;

  /// Null deshabilita el botón (p. ej. reto ya jugado hoy).
  final VoidCallback? onEmpezar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _decoracionCard.copyWith(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
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
              for (final (icono, texto) in datos)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icono, size: 16, color: AppTheme.grey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        texto,
                        style: const TextStyle(
                          color: AppTheme.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onEmpezar,
              icon: Icon(
                onEmpezar == null
                    ? Icons.check_rounded
                    : Icons.play_arrow_rounded,
              ),
              label: Text(
                boton,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: AppTheme.lightTeal,
                disabledForegroundColor: AppTheme.darkTeal,
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
    return AnimacionRespuesta(
      resultado: _animacion(estado),
      child: GestureDetector(
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
