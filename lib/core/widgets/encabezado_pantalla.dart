import 'package:flutter/material.dart';
import 'package:miapp/core/theme/app_theme.dart';

/// Encabezado destacado de las pestañas: tarjeta verde abeto con etiqueta,
/// píldora opcional y título grande.
class EncabezadoPantalla extends StatelessWidget {
  const EncabezadoPantalla({
    super.key,
    required this.etiqueta,
    this.pildora,
    required this.titulo,
    required this.subtitulo,
  });

  final String etiqueta;
  final Widget? pildora;
  final String titulo;
  final String subtitulo;

  static const _crema = AppTheme.bgCream;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
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
      child: Stack(
        children: [
          // Círculos decorativos de fondo.
          Positioned(
            right: -50,
            top: -60,
            child: _Circulo(170, _crema.withValues(alpha: 0.07)),
          ),
          Positioned(
            left: -30,
            bottom: -45,
            child: _Circulo(110, _crema.withValues(alpha: 0.05)),
          ),
          Positioned(
            right: 70,
            bottom: 18,
            child: _Circulo(14, AppTheme.tomato.withValues(alpha: 0.9)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _crema.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          etiqueta,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _crema,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    ?pildora,
                  ],
                ),
                const SizedBox(height: 18),
                // Una sola línea por cada \n del título; si no cabe, se achica.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    titulo,
                    style: const TextStyle(
                      color: _crema,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitulo,
                  style: TextStyle(
                    color: _crema.withValues(alpha: 0.75),
                    fontSize: 13.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circulo extends StatelessWidget {
  const _Circulo(this.tamano, this.color);

  final double tamano;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: tamano,
    height: tamano,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

/// Píldora de acento (rojo tomate) con ícono y texto; tocable si hay [onTap].
class PildoraInfo extends StatelessWidget {
  const PildoraInfo({
    super.key,
    required this.icono,
    required this.texto,
    this.onTap,
    this.semantica,
  });

  final IconData icono;
  final String texto;
  final VoidCallback? onTap;
  final String? semantica;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semantica,
      child: Material(
        color: AppTheme.tomato,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  texto,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
