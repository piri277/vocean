import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/core/widgets/encabezado_pantalla.dart';
import 'package:miapp/features/cultura/data/contenido_lsc.dart';
import 'package:miapp/features/cultura/views/historias_tema.dart';
import 'package:miapp/features/cultura/views/quiz_cultura.dart';
import 'package:miapp/features/perfil/providers/perfil_provider.dart';

/// Pestaña de cultura: historia, datos y comunidad alrededor de la LSC.
class CulturaView extends ConsumerWidget {
  const CulturaView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ganados = ref.watch(usuarioProvider)?.juegosGanados ?? const {};
    final todos = [for (final t in temasLsc) ...t.datos, ...datosDelDiaExtra];
    final hechos = [
      for (final t in temasLsc)
        if (ganados.contains('cultura:${t.id}')) t,
    ].length;
    final hoy = DateTime.now();
    // Cambia cada día y es el mismo durante todo el día.
    final datoDelDia =
        todos[DateTime(
              hoy.year,
              hoy.month,
              hoy.day,
            ).difference(DateTime(2026)).inDays %
            todos.length];

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const EncabezadoPantalla(
              etiqueta: 'Cultura sorda',
              titulo: 'Conoce la LSC',
              subtitulo:
                  'Historia, comunidad y datos curiosos de la Lengua de Señas Colombiana.',
            ),
            const SizedBox(height: 20),
            _DatoDelDia(dato: datoDelDia),
            const SizedBox(height: 16),
            _MitosCard(completado: ganados.contains('cultura:mitos')),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Temas',
                    style: TextStyle(
                      color: AppTheme.darkTeal,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '$hechos de ${temasLsc.length} completados',
                  style: const TextStyle(
                    color: AppTheme.tomato,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Lee las historias y responde el quiz de cada tema.',
              style: TextStyle(color: AppTheme.grey, fontSize: 13.5),
            ),
            const SizedBox(height: 12),
            for (final tema in temasLsc)
              _TemaCard(
                tema: tema,
                completado: ganados.contains('cultura:${tema.id}'),
              ),
          ],
        ),
      ),
    );
  }
}

class _DatoDelDia extends StatelessWidget {
  const _DatoDelDia({required this.dato});

  final DatoLsc dato;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.tomato,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text(
                'DATO DEL DÍA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            dato.titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dato.texto,
            style: const TextStyle(color: Colors.white, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _MitosCard extends StatelessWidget {
  const _MitosCard({required this.completado});

  final bool completado;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.darkTeal,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizCultura(
              temaId: 'mitos',
              titulo: 'Mitos y realidades',
              preguntas: mitosLsc,
              cantidad: 8,
              mezclarOpciones: false,
              completado: completado,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.bgCream.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  color: AppTheme.bgCream,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mitos y realidades',
                      style: TextStyle(
                        color: AppTheme.bgCream,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      completado
                          ? 'Completado. Juega otra vez cuando quieras.'
                          : '¿Verdadero o falso? 8 afirmaciones · +15 XP',
                      style: TextStyle(
                        color: AppTheme.bgCream.withValues(alpha: 0.75),
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                completado
                    ? Icons.check_circle_rounded
                    : Icons.play_circle_fill_rounded,
                color: AppTheme.tomato,
                size: 34,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemaCard extends StatelessWidget {
  const _TemaCard({required this.tema, required this.completado});

  final TemaLsc tema;
  final bool completado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: completado ? AppTheme.lightTeal : AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HistoriasTema(tema: tema, completado: completado),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: completado
                              ? AppTheme.darkTeal
                              : AppTheme.lightTeal,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          tema.icono,
                          color: completado
                              ? AppTheme.bgCream
                              : AppTheme.darkTeal,
                        ),
                      ),
                      if (completado)
                        Positioned(
                          right: -2,
                          bottom: -2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.tomato,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.lightTeal,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tema.titulo,
                        style: const TextStyle(
                          color: AppTheme.darkTeal,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        completado
                            ? 'Repasa cuando quieras'
                            : '${tema.datos.length} tarjetas · Quiz +15 XP',
                        style: TextStyle(
                          color: completado
                              ? AppTheme.darkTeal.withValues(alpha: 0.7)
                              : AppTheme.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (completado)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.darkTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'LISTO',
                      style: TextStyle(
                        color: AppTheme.bgCream,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.darkTeal,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
