import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/features/senas/views/widgets/icono_categoria.dart';
import 'package:miapp/features/perfil/views/racha_celebracion.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/providers/senas_provider.dart';
import 'package:miapp/features/senas/services/clasificador_letras_service.dart';
import 'package:miapp/features/senas/services/clasificador_numeros_service.dart';
import 'package:miapp/features/senas/views/practica_view.dart';
import 'package:miapp/features/senas/views/widgets/sena_chip.dart';

class SenaDetalleView extends ConsumerWidget {
  const SenaDetalleView({super.key, required this.senaId});

  final String senaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sena = ref
        .watch(senasProvider)
        .firstWhere((item) => item.id == senaId);

    final estado = sena.estadoAprendizaje;
    final imagen = imagenDeSena(senaId);
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

    Future<void> practicar() async {
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

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCream,
        foregroundColor: AppTheme.darkTeal,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          sena.categoria,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          // Imagen grande sobre tarjeta verde, con el estado encima.
          Container(
            height: 300,
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
            padding: const EdgeInsets.all(14),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.only(top: 40),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      imagen,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        iconoCategoria(sena.categoria),
                        size: 64,
                        color: AppTheme.darkTeal,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      iconoCategoria(sena.categoria),
                      color: AppTheme.bgCream,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sena.categoria.toUpperCase(),
                      style: TextStyle(
                        color: AppTheme.bgCream.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: estado is Dominada
                            ? AppTheme.tomato
                            : AppTheme.bgCream.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        etiquetaCorta(estado),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            sena.nombre,
            style: const TextStyle(
              color: AppTheme.darkTeal,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          _Tarjeta(
            icono: Icons.back_hand_outlined,
            titulo: 'Cómo se hace',
            child: Text(
              sena.descripcion,
              style: const TextStyle(
                color: AppTheme.darkTeal,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
          if (practicable) ...[
            const SizedBox(height: 12),
            _ProgresoDominio(estado: estado),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: ElevatedButton.icon(
            onPressed: practicable ? practicar : null,
            icon: const Icon(Icons.videocam_outlined),
            label: Text(
              practicable ? 'Practicar con la cámara' : 'Práctica próximamente',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
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
        '¡Seña dominada!',
        'La practicaste $diasParaDominar días. Repásala de vez en cuando.',
      ),
    };

    return _Tarjeta(
      icono: Icons.trending_up_rounded,
      titulo: titulo,
      extra: Text(
        '$dias/$diasParaDominar',
        style: const TextStyle(
          color: AppTheme.tomato,
          fontWeight: FontWeight.w900,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (var i = 0; i < diasParaDominar; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: i < dias
                          ? AppTheme.darkTeal
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
            style: const TextStyle(color: AppTheme.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta crema con ícono y título, como las del juego.
class _Tarjeta extends StatelessWidget {
  const _Tarjeta({
    required this.icono,
    required this.titulo,
    required this.child,
    this.extra,
  });

  final IconData icono;
  final String titulo;
  final Widget child;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.lightTeal,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icono, size: 18, color: AppTheme.darkTeal),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    color: AppTheme.darkTeal,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ?extra,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
