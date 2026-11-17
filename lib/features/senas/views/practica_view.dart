import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/features/perfil/providers/perfil_provider.dart';
import 'package:miapp/features/perfil/views/racha_celebracion.dart';
import 'package:miapp/features/senas/models/reconocimiento_sena_model.dart';
import 'package:miapp/features/senas/providers/practica_provider.dart';
import 'package:miapp/features/senas/providers/senas_provider.dart';
import 'package:miapp/features/senas/views/widgets/hand_landmarks_painter.dart';

/// Vista de la pantalla de práctica.
///
/// Siguiendo el Principio de Responsabilidad Única (SRP), este archivo se enfoca
/// exclusivamente en la presentación visual (UI). La gestión del hardware de la
/// cámara, las suscripciones y la integración de MediaPipe están delegadas a
/// [PracticaProvider] y [CameraDetectionService].
class PracticaView extends ConsumerStatefulWidget {
  const PracticaView({
    super.key,
    this.senaId,
    this.objetivo,
    this.imagenReferencia,
  });

  /// Seña cuyo progreso se registra al reconocerla correctamente.
  final String? senaId;

  /// Si se indica, la vista practica solo esta seña (`int` número, `String`
  /// letra) y arranca reconociendo.
  final Object? objetivo;

  /// Asset de la seña objetivo, mostrado como referencia en la esquina.
  final String? imagenReferencia;

  @override
  ConsumerState<PracticaView> createState() => _PracticaViewState();
}

class _PracticaViewState extends ConsumerState<PracticaView>
    with WidgetsBindingObserver {
  // Un día con acierto cuenta una vez: basta registrarlo una vez por pantalla.
  bool _aciertoRegistrado = false;

  /// Se devuelve al salir para que el detalle celebre la racha.
  SubidaRacha? _subidaRacha;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(practicaProvider.notifier);
      await notifier.initialize();
      if (mounted && widget.objetivo != null) {
        notifier.toggleReconocimiento(objetivo: widget.objetivo);
      }
    });
  }

  Future<void> _registrarAcierto(String senaId, double confianza) async {
    final hoy = DateTime.now();
    final anterior =
        ref.read(usuarioFutureProvider).valueOrNull?.rachaVigente(hoy) ?? 0;
    try {
      final usuario = await ref
          .read(usuarioRepositoryProvider)
          .registrarPractica(hoy);
      final nueva = usuario.rachaVigente(hoy);
      // Solo el primer acierto del día sube la racha: ahí se celebra.
      if (nueva > anterior) _subidaRacha = (anterior: anterior, nueva: nueva);
    } catch (e) {
      debugPrint('No se pudo registrar la racha: $e');
    }
    try {
      await ref
          .read(senasRepositoryProvider)
          .registrarPractica(senaId, hoy, acierto: true, precision: confianza);
      ref.invalidate(senasFutureProvider);
    } catch (e) {
      debugPrint('No se pudo registrar el acierto de $senaId: $e');
    }
    // Después de la seña, que es la que suma la XP.
    ref.invalidate(usuarioFutureProvider);
    ref.invalidate(diasPracticaProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(practicaProvider.notifier).handleAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(practicaProvider);
    ref.listen(practicaProvider.select((s) => s.resultado), (_, resultado) {
      final senaId = widget.senaId;
      if (resultado.confirmada && senaId != null && !_aciertoRegistrado) {
        _aciertoRegistrado = true;
        _registrarAcierto(senaId, resultado.confianza);
      }
    });

    return PopScope<SubidaRacha?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, _subidaRacha);
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // ── Capa de la Cámara y Esqueleto ─────────────────────────
            if (state.isReady && state.controller != null)
              // Recorta en vez de estirar: la vista previa conserva su proporción
              // (previewSize viene en horizontal, de ahí el cambio alto/ancho).
              Positioned.fill(
                child: ClipRect(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: state.controller!.value.previewSize?.height ?? 1,
                      height: state.controller!.value.previewSize?.width ?? 1,
                      child: CameraPreview(
                        state.controller!,
                        child: IgnorePointer(
                          child: CustomPaint(
                            painter: HandLandmarksPainter(
                              hands: state.detectedHands,
                              isFrontCamera: state.isFrontCamera,
                              color: _colorEsqueleto(state.resultado.estado),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF0F1720),
                  child: Center(
                    child: state.isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFF1B4532),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.videocam_off_rounded,
                                  color: Colors.white70,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.errorMessage ?? 'Cámara no disponible',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () => ref
                                      .read(practicaProvider.notifier)
                                      .initialize(),
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Reintentar'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B4532),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),

            // ── Capa de Controles y HUD Superior/Inferior ──────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(
                  children: [
                    // Título superior y foto de referencia
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (Navigator.canPop(context))
                          IconButton.filled(
                            onPressed: () => Navigator.maybePop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black.withValues(
                                alpha: 0.28,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.objetivo == null
                                ? 'Práctica'
                                : 'Practica ${_nombre(widget.objetivo!)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (widget.imagenReferencia != null)
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              widget.imagenReferencia!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.image_not_supported_outlined,
                                color: Color(0xFFBBBBBB),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const Spacer(),

                    // Botón para alternar cámara
                    if (state.canSwitchCamera)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                          width: 58,
                          height: 58,
                          child: Material(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: state.isSwitchingCamera
                                  ? null
                                  : () => ref
                                        .read(practicaProvider.notifier)
                                        .toggleCamera(),
                              child: state.isSwitchingCamera
                                  ? const Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Color(0xFF1B4532),
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.flip_camera_android_rounded,
                                      color: Color(0xFF1B4532),
                                      size: 26,
                                    ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    if (state.isReady)
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: FilledButton.icon(
                          onPressed: () => ref
                              .read(practicaProvider.notifier)
                              .toggleReconocimiento(objetivo: widget.objetivo),
                          icon: Icon(
                            state.reconociendo
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                          ),
                          label: Text(
                            state.reconociendo
                                ? 'Detener'
                                : widget.objetivo == null
                                ? 'Reconocer números'
                                : 'Reconocer seña',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4532),
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Indicador de estado de detección de la mano
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            state.hasHandsDetected
                                ? Icons.check_circle_rounded
                                : Icons.visibility_rounded,
                            color: state.hasHandsDetected
                                ? const Color(0xFF71F0C2)
                                : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              [
                                _mensaje(
                                  state.resultado,
                                  state.hasHandsDetected,
                                  widget.objetivo,
                                ),
                                if (kDebugMode &&
                                    state.reconociendo &&
                                    state.extensiones.length == 9)
                                  _puntajes(state.extensiones),
                              ].join('\n'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Verde si la seña es correcta, naranja si está cerca y rojo si no se
// reconoce; con el reconocimiento detenido conserva el color por defecto.
Color _colorEsqueleto(EstadoReconocimiento estado) => switch (estado) {
  EstadoReconocimiento.detenido => const Color(0xFF71F0C2),
  EstadoReconocimiento.confirmada => const Color(0xFF2ECC71),
  EstadoReconocimiento.analizando => const Color(0xFFFF9F1C),
  EstadoReconocimiento.sinMano ||
  EstadoReconocimiento.manoParcial ||
  EstadoReconocimiento.noReconocida => const Color(0xFFE53935),
};

// "el 3" o "la A".
String _nombre(Object sena) =>
    sena is String ? 'la ${sena.toUpperCase()}' : 'el $sena';

String _mensaje(ResultadoReconocimiento r, bool hayMano, Object? objetivo) {
  final conf = '${(r.confianza * 100).round()}%';
  return switch (r.estado) {
    EstadoReconocimiento.detenido =>
      hayMano ? 'Mano detectada' : 'Buscando mano…',
    EstadoReconocimiento.sinMano => 'No se detecta ninguna mano',
    EstadoReconocimiento.manoParcial =>
      'Mano cortada: aléjala y céntrala en la cámara',
    EstadoReconocimiento.analizando =>
      'Analizando… (¿${r.sena.toString().toUpperCase()}?)',
    EstadoReconocimiento.noReconocida =>
      objetivo == null
          ? 'Seña no reconocida'
          : 'Aún no es ${_nombre(objetivo)}',
    EstadoReconocimiento.confirmada =>
      objetivo == null
          ? 'Número ${r.sena} · confianza $conf'
          : '¡Correcto! Es ${_nombre(r.sena!)} · confianza $conf',
  };
}

// Puntajes para calibrar con manos reales: >0.5 cuenta como extendido (1.ª
// línea) o como pulgar tocando esa punta (2.ª línea).
String _puntajes(List<double> p) {
  const nombres = ['P', 'I', 'M', 'A', 'Me', 'P·I', 'P·M', 'P·A', 'P·Me'];
  String fila(int desde, int hasta) => [
    for (var i = desde; i < hasta; i++)
      '${nombres[i]} ${p[i].toStringAsFixed(2)}',
  ].join('  ');
  return '${fila(0, 5)}\n${fila(5, 9)}';
}
