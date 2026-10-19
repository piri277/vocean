import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/features/senas/providers/senas_provider.dart';
import 'package:miapp/features/senas/views/sena_detalle_view.dart';
import 'package:miapp/features/senas/views/widgets/sena_chip.dart';

class CategoriaDetalleView extends ConsumerWidget {
  const CategoriaDetalleView({super.key, required this.categoria});

  final String categoria;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final senas = ref
        .watch(senasProvider)
        .where((sena) => sena.categoria == categoria)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(categoria),
        backgroundColor: AppTheme.bgCream,
        foregroundColor: AppTheme.darkTeal,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${senas.length} señas en esta categoría',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.grey),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: senas.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final sena = senas[index];

                    return SenaChip(
                      sena: sena,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SenaDetalleView(senaId: sena.id),
                          ),
                        );
                      },
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
}
