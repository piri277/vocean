import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:miapp/core/router/route_names.dart';
import 'package:miapp/core/theme/app_theme.dart';
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
              Text(
                'Mi Perfil',
                style: GoogleFonts.nunito(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.darkTeal,
                ),
              ),
              const SizedBox(height: 16),
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
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'VOCEAN',
                      applicationLegalese:
                          'Aprende Lengua de Señas Colombiana con tu cámara.',
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
        titulo: 'Editar nombre',
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
        titulo: 'Cambiar contraseña',
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
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('Tendrás que volver a iniciar sesión.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.coral),
            child: const Text('Cerrar sesión'),
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
      messenger.showSnackBar(SnackBar(content: Text(exito)));
    } catch (e) {
      debugPrint('Error en perfil: $e');
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo guardar. Intenta de nuevo.')),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.darkTeal, AppTheme.buttonTeal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkTeal.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white,
                child: Text(
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                  style: GoogleFonts.nunito(
                    fontSize: 28,
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
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Nv. $nivel',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: avance,
              minHeight: 8,
              backgroundColor: Colors.white24,
              color: const Color(0xFFFFD54F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${xp % _xpPorNivel} / $_xpPorNivel XP para el nivel ${nivel + 1}',
            style: GoogleFonts.nunito(fontSize: 12, color: Colors.white70),
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
        icon: '🔥',
        label: 'Racha actual',
        value: '$racha ${racha == 1 ? 'día' : 'días'}',
        color: const Color(0xFFFCE4EC),
      ),
      _StatCard(
        icon: '🏆',
        label: 'Mejor racha juego',
        value: '${usuario.rachaGlobalMaxima}',
        color: const Color(0xFFFFF3E0),
      ),
      _StatCard(
        icon: '⚡',
        label: 'XP total',
        value: '${usuario.xpTotal}',
        color: const Color(0xFFFFF8E1),
      ),
      _StatCard(
        icon: '🎮',
        label: 'Partidas',
        value: '${usuario.partidasJugadas}',
        color: AppTheme.lightTeal,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: tarjetas,
    );
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
            Text(
              '${(avance * 100).round()}%',
              style: GoogleFonts.nunito(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppTheme.darkTeal,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'del diccionario dominado',
                style: GoogleFonts.nunito(color: AppTheme.grey),
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
            backgroundColor: AppTheme.ringBackground,
            color: AppTheme.buttonTeal,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _Contador('Dominadas', dominadas, AppTheme.buttonTeal),
            _Contador('En práctica', enPractica, const Color(0xFFFFA000)),
            _Contador(
              'Sin iniciar',
              total - dominadas - enPractica,
              AppTheme.grey,
            ),
          ],
        ),
      ],
    );
  }
}

class _Contador extends StatelessWidget {
  const _Contador(this.label, this.valor, this.color);

  final String label;
  final int valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$valor',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.nunito(fontSize: 12, color: AppTheme.grey),
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
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        texto,
        style: GoogleFonts.nunito(
          fontSize: 16,
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
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icono, color: color, size: 22),
      ),
      title: Text(
        titulo,
        style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: color),
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
    required this.titulo,
    required this.etiqueta,
    required this.validar,
    this.inicial = '',
    this.oculto = false,
    this.confirmar = false,
  });

  final String titulo;
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
    return AlertDialog(
      title: Text(widget.titulo),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _campo,
              autofocus: true,
              obscureText: widget.oculto,
              decoration: InputDecoration(labelText: widget.etiqueta),
              validator: (v) => widget.validar(v ?? ''),
            ),
            if (widget.confirmar)
              TextFormField(
                controller: _repetir,
                obscureText: widget.oculto,
                decoration: const InputDecoration(labelText: 'Repetir'),
                validator: (v) => v != _campo.text ? 'No coinciden' : null,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
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

  final String icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.darkTeal,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.grey,
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
