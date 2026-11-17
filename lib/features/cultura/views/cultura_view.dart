import 'package:flutter/material.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/core/widgets/encabezado_pantalla.dart';
import 'package:miapp/features/cultura/data/contenido_lsc.dart';

/// Pestaña de cultura: historia, datos y comunidad alrededor de la LSC.
class CulturaView extends StatelessWidget {
  const CulturaView({super.key});

  @override
  Widget build(BuildContext context) {
    final todos = [for (final t in temasLsc) ...t.datos];
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
            const SizedBox(height: 20),
            for (final tema in temasLsc) _TemaCard(tema: tema),
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

class _TemaCard extends StatelessWidget {
  const _TemaCard({required this.tema});

  final TemaLsc tema;

  @override
  Widget build(BuildContext context) {
    // Material (no Container): ExpansionTile pinta su fondo y su toque aquí.
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Theme(
          // Quita las líneas que ExpansionTile dibuja al abrirse.
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            iconColor: AppTheme.darkTeal,
            collapsedIconColor: AppTheme.darkTeal,
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.lightTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tema.icono, color: AppTheme.darkTeal),
            ),
            title: Text(
              tema.titulo,
              style: const TextStyle(
                color: AppTheme.darkTeal,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            subtitle: Text(
              '${tema.datos.length} datos',
              style: const TextStyle(color: AppTheme.grey, fontSize: 13),
            ),
            children: [
              for (final dato in tema.datos)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 6, right: 10),
                        decoration: const BoxDecoration(
                          color: AppTheme.tomato,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dato.titulo,
                              style: const TextStyle(
                                color: AppTheme.darkTeal,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              dato.texto,
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
            ],
          ),
        ),
      ),
    );
  }
}
