import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/core/widgets/cuadricula_dos.dart';
import 'package:miapp/features/senas/views/widgets/icono_categoria.dart';
import 'package:miapp/core/widgets/encabezado_pantalla.dart';
import 'package:miapp/features/auth/providers/auth_providers.dart';
import 'package:miapp/features/auth/providers/auth_state.dart';
import 'package:miapp/features/perfil/providers/perfil_provider.dart';
import 'package:miapp/features/perfil/views/racha_calendario.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/models/sena_model.dart';
import 'package:miapp/features/senas/providers/senas_provider.dart';
import 'package:miapp/features/senas/views/categoria_detalle_view.dart';

class DiccionarioView extends ConsumerWidget {
  const DiccionarioView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senasAsync = ref.watch(senasFutureProvider);
    final senas = ref.watch(senasProvider);
    final categorias = _agruparPorCategoria(senas);
    final authState = ref.watch(authNotifierProvider);

    final usuario = ref.watch(usuarioProvider);
    final racha = usuario?.rachaVigente(DateTime.now()) ?? 0;
    // Sin backend, el nombre del registro guardado en la sesión de Supabase.
    final nombreUsuario =
        usuario?.nombre ??
        ref.read(authServiceProvider).usuarioActual?.userMetadata?['nombre']
            as String? ??
        switch (authState) {
          AuthAuthenticated(:final email) =>
            email.contains('@') ? email.split('@').first : email,
          _ => 'Estudiante',
        };

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

    Widget estadoCentrado(Widget child) => Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(child: child),
    );

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.darkTeal,
          onRefresh: () async {
            ref.invalidate(senasFutureProvider);
            await ref.read(senasFutureProvider.future);
          },
          // Un solo ListView: el encabezado se desplaza con el contenido.
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              EncabezadoPantalla(
                etiqueta: '¡Hola, $nombreUsuario!',
                pildora: PildoraInfo(
                  icono: Icons.local_fire_department_rounded,
                  texto: '$racha',
                  semantica: 'Racha de $racha días. Ver calendario',
                  onTap: () => mostrarCalendarioRacha(context, usuario),
                ),
                titulo: '¿Qué aprenderás\nhoy?',
                subtitulo:
                    'Explora categorías y aprende a tu ritmo. Cada seña cuenta.',
              ),
              const SizedBox(height: 18),
              if (senasAsync.isLoading && senas.isEmpty)
                estadoCentrado(
                  const CircularProgressIndicator(color: AppTheme.darkTeal),
                )
              else if (senasAsync.hasError && senas.isEmpty)
                estadoCentrado(
                  Column(
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
                      ),
                    ],
                  ),
                )
              else if (categorias.isEmpty)
                estadoCentrado(
                  const Text(
                    'No hay señas disponibles por el momento.',
                    style: TextStyle(color: AppTheme.grey),
                  ),
                )
              else ...[
                _ResumenProgreso(
                  total: total,
                  dominadas: dominadas,
                  enPractica: enPractica,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Categorías',
                  style: TextStyle(
                    color: AppTheme.darkTeal,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                CuadriculaDos(
                  children: [
                    for (final entry in categorias.entries)
                      CategoriaTile(
                        categoria: entry.key,
                        categoriaSenas: entry.value,
                      ),
                  ],
                ),
              ],
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
}

/// Resumen del avance global: dominadas, en práctica y barra total.
class _ResumenProgreso extends StatelessWidget {
  const _ResumenProgreso({
    required this.total,
    required this.dominadas,
    required this.enPractica,
  });

  final int total;
  final int dominadas;
  final int enPractica;

  @override
  Widget build(BuildContext context) {
    final avance = total == 0 ? 0.0 : dominadas / total;
    Widget dato(String valor, String etiqueta, Color color) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              valor,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              etiqueta,
              maxLines: 1,
              style: const TextStyle(color: AppTheme.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              dato('$dominadas', 'Dominadas', AppTheme.darkTeal),
              dato('$enPractica', 'En práctica', AppTheme.tomato),
              dato(
                '${(avance * 100).round()}%',
                'Completado',
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
        ],
      ),
    );
  }
}

/// Tarjeta de categoría: ícono, nombre, cantidad y barra de dominadas.
class CategoriaTile extends StatelessWidget {
  const CategoriaTile({
    super.key,
    required this.categoria,
    required this.categoriaSenas,
  });

  final String categoria;
  final List<Sena> categoriaSenas;

  @override
  Widget build(BuildContext context) {
    final total = categoriaSenas.length;
    final dominadas = categoriaSenas
        .where((s) => s.estadoAprendizaje is Dominada)
        .length;
    final avance = total == 0 ? 0.0 : dominadas / total;

    return Material(
      color: AppTheme.cardBg,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CategoriaDetalleView(categoria: categoria),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTeal,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      iconoCategoria(categoria),
                      size: 34,
                      color: AppTheme.darkTeal,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: AppTheme.grey,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  categoria,
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppTheme.darkTeal,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$dominadas de $total dominadas',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.grey, fontSize: 12),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: avance,
                  minHeight: 6,
                  backgroundColor: AppTheme.ringBackground,
                  color: AppTheme.tomato,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
