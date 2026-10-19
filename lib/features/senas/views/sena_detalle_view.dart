import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/providers/senas_provider.dart';
import 'package:miapp/features/senas/services/clasificador_numeros_service.dart';
import 'package:miapp/features/senas/views/practica_view.dart';

class SenaDetalleView extends ConsumerWidget {
  const SenaDetalleView({super.key, required this.senaId});

  final String senaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sena = ref
        .watch(senasProvider)
        .firstWhere((item) => item.id == senaId);

    final estado = sena.estadoAprendizaje;
    final imagen = senaId.startsWith('num-')
        ? 'assets/numeros/${senaId.substring(4)}.png'
        : 'assets/letras/${senaId.replaceFirst('alfa-', '')}.png';
    final numero = senaId.startsWith('num-')
        ? int.tryParse(senaId.substring(4))
        : null;
    final practicable = ClasificadorNumeros.numerosSoportados.contains(numero);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Volver'),
        backgroundColor: AppTheme.bgCream,
        foregroundColor: AppTheme.darkTeal,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: _colorForCategoria(sena.categoria),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _iconForCategoria(sena.categoria),
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sena.nombre,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppTheme.darkTeal,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _colorForEstado(estado),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            estado.etiqueta,
                            style: TextStyle(
                              color: _textColorForEstado(estado),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                sena.descripcion,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF666666),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 340,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFDDDDDD), width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  imagen,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.image_not_supported_outlined,
                    size: 44,
                    color: Color(0xFFBBBBBB),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: practicable
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => PracticaView(
                              numeroObjetivo: numero,
                              imagenReferencia: imagen,
                            ),
                          ),
                        )
                      : null,
                  child: Text(
                    practicable
                        ? 'Practicar esta seña'
                        : 'Practicar esta seña (próximamente)',
                  ),
                ),
              ),
            ],
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

  Color _colorForEstado(EstadoAprendizaje estado) {
    return switch (estado) {
      Dominada() => AppTheme.lightTeal,
      EnPractica() => const Color(0xFFFFF3E0),
      NecesitaRepaso() => const Color(0xFFFDECEA),
      NoIniciada() => const Color(0xFFF5F5F5),
    };
  }

  Color _textColorForEstado(EstadoAprendizaje estado) {
    return switch (estado) {
      Dominada() => AppTheme.buttonTeal,
      EnPractica() => const Color(0xFFE65100),
      NecesitaRepaso() => const Color(0xFFB71C1C),
      NoIniciada() => AppTheme.grey,
    };
  }
}
