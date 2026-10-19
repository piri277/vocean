import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/features/auth/providers/auth_providers.dart';
import 'package:miapp/features/auth/providers/auth_state.dart';
import 'package:miapp/features/perfil/providers/perfil_provider.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/models/sena_model.dart';
import 'package:miapp/features/senas/providers/senas_provider.dart';
import 'package:miapp/features/senas/views/categoria_detalle_view.dart';
import 'package:miapp/features/senas/views/widgets/progress_ring.dart';

class DiccionarioView extends ConsumerWidget {
  const DiccionarioView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senasAsync = ref.watch(senasFutureProvider);
    final senas = ref.watch(senasProvider);
    final categorias = _agruparPorCategoria(senas);
    final authState = ref.watch(authNotifierProvider);

    final nombreUsuario =
        ref.watch(usuarioProvider)?.nombre ??
        switch (authState) {
          AuthAuthenticated(:final email) =>
            email.contains('@') ? email.split('@').first : email,
          _ => 'Estudiante',
        };

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          color: AppTheme.darkTeal,
                        ),
                        children: [
                          TextSpan(
                            text: '¡Hola, $nombreUsuario! ',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const TextSpan(
                            text: '👋',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F4EC),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Text('🔥', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 4),
                        Text(
                          'Activo',
                          style: TextStyle(
                            color: AppTheme.darkTeal,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Qué aprenderás\nhoy?',
                style: TextStyle(
                  color: AppTheme.darkTeal,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Explora categorías y aprende a tu ritmo. Cada seña cuenta.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (senasAsync.isLoading && senas.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.darkTeal,
                        ),
                      );
                    }

                    if (senasAsync.hasError && senas.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 48,
                              color: AppTheme.grey,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No se pudieron cargar las señas.',
                              style: TextStyle(
                                color: AppTheme.darkTeal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => ref.refresh(senasFutureProvider),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reintentar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.darkTeal,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (categorias.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay señas disponibles por el momento.',
                          style: TextStyle(color: AppTheme.grey),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(senasFutureProvider);
                        await ref.read(senasFutureProvider.future);
                      },
                      color: AppTheme.darkTeal,
                      child: ListView.separated(
                        itemCount: categorias.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = categorias.entries.elementAt(index);
                          final categoria = entry.key;
                          final categoriaSenas = entry.value;
                          final progreso = _promedioCategoria(categoriaSenas);

                          return CategoriaTile(
                            categoria: categoria,
                            categoriaSenas: categoriaSenas,
                            progreso: progreso,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, List<Sena>> _agruparPorCategoria(List<Sena> senas) {
    final grouped = <String, List<Sena>>{};

    for (final sena in senas) {
      grouped.putIfAbsent(sena.categoria, () => <Sena>[]).add(sena);
    }

    return grouped;
  }

  double _promedioCategoria(List<Sena> senas) {
    if (senas.isEmpty) return 0;

    final total = senas.fold<double>(0, (sum, sena) {
      return sum + _progressForSena(sena);
    });

    return (total / senas.length).clamp(0.0, 1.0);
  }

  double _progressForSena(Sena sena) {
    return switch (sena.estadoAprendizaje) {
      Dominada(:final precision) => precision.clamp(0.0, 1.0),
      EnPractica() => 0.35,
      NecesitaRepaso() => 0.28,
      NoIniciada() => 0.0,
    };
  }
}

class CategoriaTile extends StatefulWidget {
  const CategoriaTile({
    super.key,
    required this.categoria,
    required this.categoriaSenas,
    required this.progreso,
  });

  final String categoria;
  final List<Sena> categoriaSenas;
  final double progreso;

  @override
  State<CategoriaTile> createState() => _CategoriaTileState();
}

class _CategoriaTileState extends State<CategoriaTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    CategoriaDetalleView(categoria: widget.categoria),
              ),
            );
          },
          borderRadius: BorderRadius.circular(28),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: _pressed ? 0.06 : 0.03),
                  blurRadius: _pressed ? 14 : 10,
                  offset: Offset(0, _pressed ? 5 : 3),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Row(
              children: [
                CategoryDropletIcon(
                  color: _colorForCategoria(widget.categoria),
                  emoji: _iconForCategoria(widget.categoria),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.categoria,
                        style: const TextStyle(
                          color: AppTheme.darkTeal,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.categoriaSenas.length} de ${widget.categoriaSenas.length + 2} señas',
                        style: TextStyle(color: AppTheme.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ProgressRing(progress: widget.progreso, size: 42),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForCategoria(String categoria) {
    switch (categoria) {
      case 'Alfabeto':
        return AppTheme.lightTeal;
      case 'Saludos':
        return const Color(0xFFFCE4EC);
      case 'Números':
        return const Color(0xFFFFF8E1);
      case 'Emergencias':
        return const Color(0xFFEDE7F6);
      default:
        return AppTheme.lightTeal;
    }
  }

  String _iconForCategoria(String categoria) {
    switch (categoria) {
      case 'Alfabeto':
        return '🤟';
      case 'Saludos':
        return '🖐️';
      case 'Números':
        return '🤙';
      case 'Emergencias':
        return '🤝';
      default:
        return '✋';
    }
  }
}

class CategoryDropletIcon extends StatelessWidget {
  const CategoryDropletIcon({
    super.key,
    required this.color,
    required this.emoji,
  });

  final Color color;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.center,
        child: Text(emoji, style: const TextStyle(fontSize: 34)),
      ),
    );
  }
}
