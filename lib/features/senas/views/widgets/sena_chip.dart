import 'package:flutter/material.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/models/sena_model.dart';

class SenaChip extends StatelessWidget {
  const SenaChip({super.key, required this.sena, this.onTap});

  final Sena sena;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _colorForCategoria(sena.categoria),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  _iconForSena(sena),
                  style: const TextStyle(
                    color: AppTheme.darkTeal,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sena.nombre,
                      style: const TextStyle(
                        color: AppTheme.darkTeal,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _resumenDescripcion(sena.descripcion),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.grey,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _colorForEstado(sena.estadoAprendizaje),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _labelForEstado(sena.estadoAprendizaje),
                  style: TextStyle(
                    color: _textColorForEstado(sena.estadoAprendizaje),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _iconForSena(Sena sena) {
    switch (sena.categoria) {
      case 'Alfabeto':
        final letras = sena.nombre.replaceAll(RegExp(r'[^A-Za-z]'), '');
        return letras.isNotEmpty ? letras.substring(0, 1).toUpperCase() : 'A';
      case 'Saludos':
        return '👋';
      case 'Números':
        return '✋';
      case 'Emergencias':
        return '🆘';
      default:
        return '✋';
    }
  }

  String _resumenDescripcion(String descripcion) {
    if (descripcion.length <= 52) {
      return descripcion;
    }
    return '${descripcion.substring(0, 52)}...';
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

  String _labelForEstado(EstadoAprendizaje estado) {
    return switch (estado) {
      Dominada() => 'Dominada',
      EnPractica() => 'En práctica',
      NecesitaRepaso() => 'Repaso',
      NoIniciada() => 'Sin iniciar',
    };
  }
}
