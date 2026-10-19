import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/features/senas/models/reconocimiento_numero_model.dart';
import 'package:miapp/features/senas/providers/practica_provider.dart';
import 'package:miapp/features/senas/views/widgets/hand_landmarks_painter.dart';

/// Vista de la pantalla de práctica.
///
/// Siguiendo el Principio de Responsabilidad Única (SRP), este archivo se enfoca
/// exclusivamente en la presentación visual (UI). La gestión del hardware de la
/// cámara, las suscripciones y la integración de MediaPipe están delegadas a
/// [PracticaProvider] y [CameraDetectionService].
class PracticaView extends ConsumerStatefulWidget {
  const PracticaView({super.key, this.numeroObjetivo, this.imagenReferencia});

  /// Si se indica, la vista practica solo este número y arranca reconociendo.
  final int? numeroObjetivo;

  /// Asset de la seña objetivo, mostrado como referencia en la esquina.
  final String? imagenReferencia;

  @override
  ConsumerState<PracticaView> createState() => _PracticaViewState();
}

class _PracticaViewState extends ConsumerState<PracticaView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(practicaProvider.notifier);
      await notifier.initialize();
      if (mounted && widget.numeroObjetivo != null) {
        notifier.toggleReconocimiento(objetivo: widget.numeroObjetivo);
      }
    });
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Capa de la Cámara y Esqueleto ─────────────────────────
          if (state.isReady && state.controller != null)
            Positioned.fill(
              child: CameraPreview(
                state.controller!,
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: HandLandmarksPainter(
                      hands: state.detectedHands,
                      isFrontCamera: state.isFrontCamera,
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
                          color: Color(0xFF136862),
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
                                  backgroundColor: const Color(0xFF136862),
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
                          onPressed: () => Navigator.pop(context),
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
                          widget.numeroObjetivo == null
                              ? 'Práctica'
                              : 'Practica el ${widget.numeroObjetivo}',
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
                                        color: Color(0xFF136862),
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.flip_camera_android_rounded,
                                    color: Color(0xFF136862),
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
                            .toggleReconocimiento(
                              objetivo: widget.numeroObjetivo,
                            ),
                        icon: Icon(
                          state.reconociendo
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                        ),
                        label: Text(
                          state.reconociendo ? 'Detener' : 'Reconocer números',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF136862),
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
                                widget.numeroObjetivo,
                              ),
                              if (state.reconociendo &&
                                  state.extensiones.length == 5)
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
    );
  }
}

String _mensaje(ResultadoReconocimiento r, bool hayMano, int? objetivo) {
  final conf = '${(r.confianza * 100).round()}%';
  return switch (r.estado) {
    EstadoReconocimiento.detenido =>
      hayMano ? 'Mano detectada' : 'Buscando mano…',
    EstadoReconocimiento.sinMano => 'No se detecta ninguna mano',
    EstadoReconocimiento.manoParcial =>
      'Mano cortada: aléjala y céntrala en la cámara',
    EstadoReconocimiento.analizando => 'Analizando… (¿${r.numero}?)',
    EstadoReconocimiento.noReconocida =>
      objetivo == null ? 'Seña no reconocida' : 'Aún no es el $objetivo',
    EstadoReconocimiento.confirmada =>
      objetivo == null
          ? 'Número ${r.numero} · confianza $conf'
          : '¡Correcto! Número ${r.numero} · confianza $conf',
  };
}

// Puntaje por dedo para calibrar con manos reales: >0.5 cuenta como extendido.
String _puntajes(List<double> ext) {
  const nombres = ['P', 'I', 'M', 'A', 'Me'];
  return [
    for (var i = 0; i < 5; i++) '${nombres[i]} ${ext[i].toStringAsFixed(2)}',
  ].join('  ');
}
