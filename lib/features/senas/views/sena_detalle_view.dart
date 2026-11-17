import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/features/perfil/views/racha_celebracion.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/providers/senas_provider.dart';
import 'package:miapp/features/senas/services/clasificador_letras_service.dart';
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
    final letra = senaId.startsWith('alfa-') ? senaId.substring(5) : null;
    final Object? objetivo =
        ClasificadorNumeros.numerosSoportados.contains(numero)
        ? numero
        : ClasificadorLetras.letrasSoportadas.contains(letra)
        ? letra
        : null;
    final practicable = objetivo != null;

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
              if (practicable) ...[
                const SizedBox(height: 20),
                _ProgresoDominio(estado: estado),
              ],
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
                      ? () async {
                          _iniciarPractica(ref);
                          // La cámara devuelve la subida de racha si hubo acierto.
                          final racha = await Navigator.push(
                            context,
                            MaterialPageRoute<SubidaRacha?>(
                              builder: (_) => PracticaView(
                                senaId: senaId,
                                objetivo: objetivo,
                                imagenReferencia: imagen,
                              ),
                            ),
                          );
                          if (racha != null && context.mounted) {
                            mostrarCelebracionRacha(
                              context,
                              anterior: racha.anterior,
                              nueva: racha.nueva,
                            );
                          }
                        }
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

  /// Pasa la seña a «en práctica». Si el backend falla, la práctica sigue igual.
  Future<void> _iniciarPractica(WidgetRef ref) async {
    final hoy = DateTime.now();
    try {
      await ref.read(senasRepositoryProvider).registrarPractica(senaId, hoy);
      ref.invalidate(senasFutureProvider);
    } catch (e) {
      debugPrint('No se pudo iniciar la práctica de $senaId: $e');
    }
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

/// Cuántos días lleva practicando la seña y cuántos le faltan para dominarla.
class _ProgresoDominio extends StatelessWidget {
  const _ProgresoDominio({required this.estado});

  final EstadoAprendizaje estado;

  @override
  Widget build(BuildContext context) {
    final hoy = DateTime.now();
    final (int dias, String titulo, String detalle) = switch (estado) {
      NoIniciada() => (
        0,
        'Empieza a practicar',
        'Reconócela bien en $diasParaDominar días distintos para dominarla.',
      ),
      final EnPractica e => (
        e.intentos,
        'Sigue practicando ${e.diasRestantes} '
            '${e.diasRestantes == 1 ? 'día' : 'días'} más para dominarla',
        e.contoHoy(hoy)
            ? '¡Hoy ya cuenta! Vuelve mañana para sumar otro día.'
            : 'Haz la seña correctamente hoy para sumar un día.',
      ),
      NecesitaRepaso(:final motivo) => (
        0,
        'Necesita repaso',
        '$motivo. Practícala de nuevo para recuperarla.',
      ),
      Dominada() => (
        diasParaDominar,
        '¡Seña dominada! 🎉',
        'La practicaste $diasParaDominar días. Repásala de vez en cuando.',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: AppTheme.darkTeal,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '$dias/$diasParaDominar días',
                style: const TextStyle(
                  color: AppTheme.buttonTeal,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < diasParaDominar; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: i < dias
                          ? AppTheme.buttonTeal
                          : AppTheme.ringBackground,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            detalle,
            style: const TextStyle(color: Color(0xFF666666), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
