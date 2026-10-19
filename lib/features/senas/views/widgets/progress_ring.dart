import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:miapp/core/theme/app_theme.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({super.key, required this.progress, this.size = 38});

  final double progress;
  final double size;

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentage = (clampedProgress * 100).round();

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clampedProgress,
              strokeWidth: 3,
              backgroundColor: AppTheme.ringBackground,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.buttonTeal,
              ),
            ),
          ),
          Transform.rotate(
            angle: -math.pi / 2,
            child: SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: clampedProgress,
                strokeWidth: 3,
                strokeCap: StrokeCap.round,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.buttonTeal,
                ),
              ),
            ),
          ),
          Text(
            '$percentage%',
            style: const TextStyle(
              color: AppTheme.darkTeal,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
