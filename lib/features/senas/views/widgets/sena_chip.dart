import 'package:flutter/material.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/models/sena_model.dart';
import 'package:miapp/features/senas/views/widgets/icono_categoria.dart';

/// Tarjeta de una seña para la cuadrícula de la categoría:
/// imagen de referencia, nombre y estado de aprendizaje.
class SenaChip extends StatelessWidget {
  const SenaChip({super.key, required this.sena, this.onTap});

  final Sena sena;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final estado = sena.estadoAprendizaje;
    final dominada = estado is Dominada;
    return Material(
      color: AppTheme.cardBg,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Positioned.fill: el fondo ocupa todo el alto aunque no haya imagen.
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.lightTeal,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          imagenDeSena(sena.id),
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => _SinImagen(sena: sena),
                        ),
                      ),
                    ),
                    if (dominada)
                      const Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(
                          Icons.verified_rounded,
                          size: 18,
                          color: AppTheme.tomato,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sena.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.darkTeal,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: colorEstado(estado),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      etiquetaCorta(estado),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
            ],
          ),
        ),
      ),
    );
  }
}

/// Relleno cuando la seña no tiene imagen: su número, o el ícono de la categoría.
class _SinImagen extends StatelessWidget {
  const _SinImagen({required this.sena});

  final Sena sena;

  @override
  Widget build(BuildContext context) {
    final numero = sena.id.startsWith('num-') ? sena.id.substring(4) : null;
    return Center(
      child: numero != null
          ? Text(
              numero,
              style: const TextStyle(
                color: AppTheme.darkTeal,
                fontSize: 40,
                fontWeight: FontWeight.w900,
              ),
            )
          : Icon(
              iconoCategoria(sena.categoria),
              size: 40,
              color: AppTheme.darkTeal,
            ),
    );
  }
}

/// Color que identifica cada estado (punto y filtros).
Color colorEstado(EstadoAprendizaje estado) => switch (estado) {
  Dominada() => AppTheme.darkTeal,
  EnPractica() => AppTheme.tomato,
  NecesitaRepaso() => const Color(0xFFA82A17),
  NoIniciada() => AppTheme.ringBackground,
};

String etiquetaCorta(EstadoAprendizaje estado) => switch (estado) {
  Dominada() => 'Dominada',
  EnPractica() => 'En práctica',
  NecesitaRepaso() => 'Repaso',
  NoIniciada() => 'Sin iniciar',
};
