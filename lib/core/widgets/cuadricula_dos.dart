import 'package:flutter/material.dart';

/// Cuadrícula de 2 columnas cuyas filas miden lo que su tarjeta más alta.
/// A diferencia de GridView no fija el alto, así no se desborda con letra grande.
class CuadriculaDos extends StatelessWidget {
  const CuadriculaDos({super.key, required this.children, this.espacio = 12});

  final List<Widget> children;
  final double espacio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i += 2) ...[
          if (i > 0) SizedBox(height: espacio),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: children[i]),
                SizedBox(width: espacio),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
