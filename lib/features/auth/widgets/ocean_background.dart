import 'package:flutter/material.dart';

class OceanBackground extends StatelessWidget {
  final Widget child;

  const OceanBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final Color waveFillColor = const Color(0xFFEBE0D3);
    final Color waveLineColor = const Color(0xFFD9CCBE);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 180,
          child: CustomPaint(
            painter: _TopWavePainter(
              fillColor: waveFillColor,
              lineColor: waveLineColor,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 220,
          child: CustomPaint(
            painter: _BottomWavePainter(
              fillColor: waveFillColor,
              lineColor: waveLineColor,
            ),
          ),
        ),
        SafeArea(child: child),
      ],
    );
  }
}

class _TopWavePainter extends CustomPainter {
  final Color fillColor;
  final Color lineColor;

  _TopWavePainter({required this.fillColor, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.9,
      size.width * 0.55,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.1,
      size.width,
      size.height * 0.6,
    );

    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, fillPaint);

    final linePath = Path();
    linePath.moveTo(0, size.height * 0.4);
    linePath.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.9,
      size.width * 0.55,
      size.height * 0.5,
    );
    linePath.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.1,
      size.width,
      size.height * 0.6,
    );
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottomWavePainter extends CustomPainter {
  final Color fillColor;
  final Color lineColor;

  _BottomWavePainter({required this.fillColor, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 1.1,
      size.width,
      size.height * 0.4,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);

    final linePath = Path();
    linePath.moveTo(0, size.height * 0.6);
    linePath.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.7,
    );
    linePath.quadraticBezierTo(
      size.width * 0.85,
      size.height * 1.1,
      size.width,
      size.height * 0.4,
    );
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
