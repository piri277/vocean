import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:miapp/core/router/route_names.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/core/widgets/cuadricula_dos.dart';
import 'package:miapp/core/widgets/dialogo_app.dart';
import 'package:miapp/features/auth/providers/auth_providers.dart';
import 'package:miapp/features/auth/providers/auth_state.dart';
import 'package:miapp/features/perfil/models/usuario_model.dart';
import 'package:miapp/features/perfil/providers/perfil_provider.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/providers/senas_provider.dart';

/// XP necesaria para subir cada nivel.
const _xpPorNivel = 100;

/// Perfil del usuario: resumen, estadísticas, progreso y ajustes de cuenta.
class PerfilView extends ConsumerWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioAsync = ref.watch(usuarioFutureProvider);
    final usuario = usuarioAsync.value;
    final authState = ref.watch(authNotifierProvider);
    final email = switch (authState) {
      AuthAuthenticated(:final email) => email,
      _ => ref.read(authServiceProvider).usuarioActual?.email ?? '',
    };
    final nombre =
        usuario?.nombre ??
        ref.read(authServiceProvider).usuarioActual?.userMetadata?['nombre']
            as String? ??
        (email.contains('@') ? email.split('@').first : 'Usuario');

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.darkTeal,
          onRefresh: () async {
            ref.invalidate(usuarioFutureProvider);
            ref.invalidate(senasFutureProvider);
            await ref.read(usuarioFutureProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              _Cabecera(nombre: nombre, email: email, usuario: usuario),
              const SizedBox(height: 20),
              if (usuarioAsync.hasError)
                const _Aviso('No se pudieron cargar las estadísticas.')
              else if (usuario == null)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.darkTeal),
                  ),
                )
              else
                _Estadisticas(usuario: usuario),
              const SizedBox(height: 24),
              const _Titulo('Mi aprendizaje'),
              const _ProgresoAprendizaje(),
              const SizedBox(height: 24),
              const _Titulo('Cuenta'),
              _Grupo(
                children: [
                  _Opcion(
                    icono: Icons.badge_outlined,
                    titulo: 'Nombre',
                    subtitulo: nombre,
                    onTap: () => _editarNombre(context, ref, nombre),
                  ),
                  _Opcion(
                    icono: Icons.alternate_email_rounded,
                    titulo: 'Correo',
                    subtitulo: email,
                  ),
                  _Opcion(
                    icono: Icons.lock_outline_rounded,
                    titulo: 'Cambiar contraseña',
                    onTap: () => _cambiarContrasena(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const _Titulo('Más'),
              _Grupo(
                children: [
                  _Opcion(
                    icono: Icons.info_outline_rounded,
                    titulo: 'Acerca de VOCEAN',
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) => const _AcercaDe(),
                    ),
                  ),
                  _Opcion(
                    icono: Icons.logout_rounded,
                    titulo: 'Cerrar sesión',
                    color: AppTheme.coral,
                    onTap: () => _cerrarSesion(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editarNombre(
    BuildContext context,
    WidgetRef ref,
    String actual,
  ) async {
    final nuevo = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoTexto(
        icono: Icons.badge_outlined,
        titulo: 'Editar nombre',
        descripcion: 'Así te verán en la app.',
        etiqueta: 'Nombre',
        inicial: actual,
        validar: (v) {
          final t = v.trim();
          if (t.length < 2) return 'Mínimo 2 caracteres';
          if (t.length > 40) return 'Máximo 40 caracteres';
          return null;
        },
      ),
    );
    if (nuevo == null || nuevo.trim() == actual || !context.mounted) return;
    await _ejecutar(context, 'Nombre actualizado', () async {
      await ref.read(usuarioRepositoryProvider).actualizarNombre(nuevo);
      ref.invalidate(usuarioFutureProvider);
    });
  }

  Future<void> _cambiarContrasena(BuildContext context, WidgetRef ref) async {
    final nueva = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoTexto(
        icono: Icons.lock_outline_rounded,
        titulo: 'Cambiar contraseña',
        descripcion: 'Usa al menos 6 caracteres.',
        etiqueta: 'Nueva contraseña',
        oculto: true,
        confirmar: true,
        validar: (v) => v.length < 6 ? 'Mínimo 6 caracteres' : null,
      ),
    );
    if (nueva == null || !context.mounted) return;
    await _ejecutar(
      context,
      'Contraseña actualizada',
      () => ref.read(authServiceProvider).cambiarContrasena(nueva),
    );
  }

  Future<void> _cerrarSesion(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => DialogoApp(
        icono: Icons.logout_rounded,
        colorIcono: AppTheme.tomato,
        titulo: '¿Cerrar sesión?',
        descripcion:
            'Tu progreso queda guardado. Tendrás que volver a iniciar sesión.',
        acciones: [
          BotonDialogo.secundario(
            texto: 'Cancelar',
            onPressed: () => Navigator.pop(ctx, false),
          ),
          BotonDialogo(
            texto: 'Salir',
            color: AppTheme.tomato,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(authNotifierProvider.notifier).logout();
    if (context.mounted) context.go(RouteNames.loginPath);
  }

  /// Ejecuta [accion] y muestra el resultado en un SnackBar.
  Future<void> _ejecutar(
    BuildContext context,
    String exito,
    Future<void> Function() accion,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await accion();
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: AppTheme.bgCream),
              const SizedBox(width: 10),
              Expanded(child: Text(exito)),
            ],
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error en perfil: $e');
      messenger.showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.tomato,
          content: Text('No se pudo guardar. Intenta de nuevo.'),
        ),
      );
    }
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.nombre,
    required this.email,
    required this.usuario,
  });

  final String nombre;
  final String email;
  final Usuario? usuario;

  @override
  Widget build(BuildContext context) {
    final xp = usuario?.xpTotal ?? 0;
    final nivel = xp ~/ _xpPorNivel + 1;
    final avance = (xp % _xpPorNivel) / _xpPorNivel;

    const crema = AppTheme.bgCream;
    Widget circulo(double t, Color c) => Container(
      width: t,
      height: t,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.darkTeal,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkTeal.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -60,
            child: circulo(170, crema.withValues(alpha: 0.07)),
          ),
          Positioned(
            left: -30,
            bottom: -45,
            child: circulo(110, crema.withValues(alpha: 0.05)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: crema,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: crema.withValues(alpha: 0.35),
                          width: 4,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                      ),
                      child: Text(
                        nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.darkTeal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: crema,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: crema.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.tomato,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Nivel $nivel',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${xp % _xpPorNivel} / $_xpPorNivel XP',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: crema.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: avance,
                    minHeight: 10,
                    backgroundColor: crema.withValues(alpha: 0.15),
                    color: AppTheme.tomato,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Te faltan ${_xpPorNivel - xp % _xpPorNivel} XP para el nivel ${nivel + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    color: crema.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Estadisticas extends StatelessWidget {
  const _Estadisticas({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    final racha = usuario.rachaVigente(DateTime.now());
    final tarjetas = [
      _StatCard(
        icon: const Icon(
          Icons.local_fire_department_outlined,
          size: 26,
          color: AppTheme.tomato,
        ),
        label: 'Racha actual',
        value: '$racha ${racha == 1 ? 'día' : 'días'}',
        color: const Color(0xFFF5D3C6),
      ),
      _StatCard(
        icon: const Icon(
          Icons.emoji_events_outlined,
          size: 26,
          color: AppTheme.darkTeal,
        ),
        label: 'Mejor racha juego',
        value: '${usuario.rachaGlobalMaxima}',
        color: AppTheme.lightTeal,
      ),
      _StatCard(
        icon: const Icon(
          Icons.bolt_rounded,
          size: 26,
          color: AppTheme.darkTeal,
        ),
        label: 'XP total',
        value: '${usuario.xpTotal}',
        color: AppTheme.lightTeal,
      ),
      _StatCard(
        icon: const Icon(
          Icons.sports_esports_outlined,
          size: 26,
          color: AppTheme.darkTeal,
        ),
        label: 'Partidas',
        value: '${usuario.partidasJugadas}',
        color: AppTheme.lightTeal,
      ),
    ];
    return CuadriculaDos(children: tarjetas);
  }
}

class _ProgresoAprendizaje extends ConsumerWidget {
  const _ProgresoAprendizaje();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senas = ref.watch(senasProvider);
    final total = senas.length;
    final dominadas = senas
        .where((s) => s.estadoAprendizaje is Dominada)
        .length;
    final enPractica = senas
        .where(
          (s) =>
              s.estadoAprendizaje is EnPractica ||
              s.estadoAprendizaje is NecesitaRepaso,
        )
        .length;
    final avance = total == 0 ? 0.0 : dominadas / total;

    return _Grupo(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            _Contador('Dominadas', '$dominadas', AppTheme.darkTeal),
            _Contador('En práctica', '$enPractica', AppTheme.tomato),
            _Contador(
              'Completado',
              '${(avance * 100).round()}%',
              AppTheme.darkTeal,
            ),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: avance,
            minHeight: 10,
            backgroundColor: AppTheme.ringBackground,
            color: AppTheme.darkTeal,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${total - dominadas - enPractica} señas sin iniciar de $total',
          style: const TextStyle(fontSize: 12, color: AppTheme.grey),
        ),
      ],
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador(this.label, this.valor, this.color);

  final String label;
  final String valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: GoogleFonts.nunito(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        texto,
        style: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppTheme.darkTeal,
        ),
      ),
    );
  }
}

/// Tarjeta blanca que agrupa filas de contenido.
class _Grupo extends StatelessWidget {
  const _Grupo({required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    // Material (no Container): ListTile dibuja su fondo y su toque aquí.
    return Material(
      color: AppTheme.cardBg,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  const _Opcion({
    required this.icono,
    required this.titulo,
    this.subtitulo,
    this.onTap,
    this.color = AppTheme.darkTeal,
  });

  final IconData icono;
  final String titulo;
  final String? subtitulo;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: color == AppTheme.darkTeal
              ? AppTheme.lightTeal
              : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icono, color: color, size: 22),
      ),
      title: Text(
        titulo,
        style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: color),
      ),
      subtitle: subtitulo == null
          ? null
          : Text(
              subtitulo!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(color: AppTheme.grey),
            ),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right_rounded, color: AppTheme.grey),
    );
  }
}

class _Aviso extends StatelessWidget {
  const _Aviso(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return _Grupo(
      padding: const EdgeInsets.all(16),
      children: [Text(texto, style: const TextStyle(color: AppTheme.coral))],
    );
  }
}

/// Diálogo con un campo de texto validado; devuelve el valor al guardar.
class _DialogoTexto extends StatefulWidget {
  const _DialogoTexto({
    required this.icono,
    required this.titulo,
    required this.descripcion,
    required this.etiqueta,
    required this.validar,
    this.inicial = '',
    this.oculto = false,
    this.confirmar = false,
  });

  final IconData icono;
  final String titulo;
  final String descripcion;
  final String etiqueta;
  final String inicial;
  final bool oculto;

  /// Pide repetir el valor (para contraseñas).
  final bool confirmar;
  final String? Function(String) validar;

  @override
  State<_DialogoTexto> createState() => _DialogoTextoState();
}

class _DialogoTextoState extends State<_DialogoTexto> {
  final _form = GlobalKey<FormState>();
  late final _campo = TextEditingController(text: widget.inicial);
  final _repetir = TextEditingController();
  late bool _ocultar = widget.oculto;

  @override
  void dispose() {
    _campo.dispose();
    _repetir.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_form.currentState!.validate()) Navigator.pop(context, _campo.text);
  }

  @override
  Widget build(BuildContext context) {
    final ojo = widget.oculto
        ? IconButton(
            tooltip: _ocultar ? 'Mostrar' : 'Ocultar',
            icon: Icon(
              _ocultar
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppTheme.grey,
            ),
            onPressed: () => setState(() => _ocultar = !_ocultar),
          )
        : null;
    return DialogoApp(
      icono: widget.icono,
      titulo: widget.titulo,
      descripcion: widget.descripcion,
      contenido: Form(
        key: _form,
        child: Column(
          children: [
            TextFormField(
              controller: _campo,
              autofocus: true,
              obscureText: _ocultar,
              style: const TextStyle(
                color: AppTheme.darkTeal,
                fontWeight: FontWeight.w700,
              ),
              decoration: decoracionCampo(
                hint: widget.etiqueta,
                icono: widget.icono,
                sufijo: ojo,
              ),
              validator: (v) => widget.validar(v ?? ''),
              onFieldSubmitted: (_) => widget.confirmar ? null : _guardar(),
            ),
            if (widget.confirmar) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _repetir,
                obscureText: _ocultar,
                style: const TextStyle(
                  color: AppTheme.darkTeal,
                  fontWeight: FontWeight.w700,
                ),
                decoration: decoracionCampo(
                  hint: 'Repite la contraseña',
                  icono: Icons.lock_reset_rounded,
                ),
                validator: (v) => v != _campo.text ? 'No coinciden' : null,
                onFieldSubmitted: (_) => _guardar(),
              ),
            ],
          ],
        ),
      ),
      acciones: [
        BotonDialogo.secundario(
          texto: 'Cancelar',
          onPressed: () => Navigator.pop(context),
        ),
        BotonDialogo(texto: 'Guardar', onPressed: _guardar),
      ],
    );
  }
}

/// Ventana «Acerca de VOCEAN»: qué es la app y qué trae.
class _AcercaDe extends StatelessWidget {
  const _AcercaDe();

  @override
  Widget build(BuildContext context) {
    Widget fila(IconData icono, String titulo, String texto) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.lightTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, size: 19, color: AppTheme.darkTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: AppTheme.darkTeal,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  texto,
                  style: const TextStyle(color: AppTheme.grey, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return DialogoApp(
      icono: Icons.sign_language_rounded,
      titulo: 'VOCEAN',
      descripcion: 'Aprende Lengua de Señas Colombiana con tu cámara.',
      contenido: Column(
        children: [
          fila(
            Icons.menu_book_outlined,
            'Diccionario',
            'Señas por categoría con su imagen de referencia.',
          ),
          fila(
            Icons.videocam_outlined,
            'Práctica con cámara',
            'Reconoce tu seña en tiempo real y domínala en 3 días.',
          ),
          fila(
            Icons.sports_esports_outlined,
            'Juego',
            'Adivina palabras y números formados con señas.',
          ),
          fila(
            Icons.auto_stories_outlined,
            'Cultura',
            'Historia y datos de la comunidad sorda.',
          ),
          const SizedBox(height: 4),
          const Text(
            'Versión 1.0.0',
            style: TextStyle(color: AppTheme.grey, fontSize: 12),
          ),
        ],
      ),
      acciones: [
        BotonDialogo.secundario(
          texto: 'Licencias',
          onPressed: () =>
              showLicensePage(context: context, applicationName: 'VOCEAN'),
        ),
        BotonDialogo(texto: 'Cerrar', onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final Widget icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: icon,
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.darkTeal,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(fontSize: 12, color: AppTheme.grey),
            ),
          ),
        ],
      ),
    );
  }
}
