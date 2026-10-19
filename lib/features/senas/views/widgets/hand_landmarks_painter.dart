import 'package:flutter/material.dart';

/// Painter encargado exclusivamente de dibujar el esqueleto y los puntos clave
/// de las manos detectadas por MediaPipe sobre el preview de la cámara.
class HandLandmarksPainter extends CustomPainter {
  const HandLandmarksPainter({
    required this.hands,
    required this.isFrontCamera,
  });

  /// Lista de manos detectadas, donde cada mano contiene los puntos normalizados (0.0 a 1.0).
  final List<List<Offset>> hands;

  /// Indica si la cámara activa es la frontal (para invertir el eje correspondiente).
  final bool isFrontCamera;

  /// Conexiones anatómicas entre los 21 puntos clave de la mano según MediaPipe.
  static const List<List<int>> _connections = [
    [0, 1],
    [1, 2],
    [2, 3],
    [3, 4], // Pulgar
    [0, 5],
    [5, 6],
    [6, 7],
    [7, 8], // Índice
    [5, 9],
    [9, 10],
    [10, 11],
    [11, 12], // Medio
    [9, 13],
    [13, 14],
    [14, 15],
    [15, 16], // Anular
    [13, 17],
    [17, 18],
    [18, 19],
    [19, 20], // Meñique
    [0, 17], // Base de la palma
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (hands.isEmpty) return;

    final linePaint = Paint()
      ..color = const Color(0xFF71F0C2)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = const Color(0xFF71F0C2)
      ..style = PaintingStyle.fill;

    // Helper para transformar las coordenadas del sensor de MediaPipe a la pantalla.
    // La imagen cruda de la cámara está en horizontal (landscape), por lo que
    // X e Y están invertidos respecto a la pantalla en vertical (portrait).
    Offset mapPoint(Offset p) {
      final x = 1.0 - p.dy;
      final y = isFrontCamera ? 1.0 - p.dx : p.dx;
      return Offset(x * size.width, y * size.height);
    }

    for (final hand in hands) {
      for (final connection in _connections) {
        final a = mapPoint(hand[connection[0]]);
        final b = mapPoint(hand[connection[1]]);
        canvas.drawLine(a, b, linePaint);
      }

      for (final landmark in hand) {
        canvas.drawCircle(mapPoint(landmark), 5, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HandLandmarksPainter oldDelegate) => true;
}
