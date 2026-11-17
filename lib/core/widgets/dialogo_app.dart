import 'package:flutter/material.dart';
import 'package:miapp/core/theme/app_theme.dart';

/// Ventana emergente con el estilo de la app: ícono en círculo, título,
/// descripción opcional, contenido y botones abajo.
class DialogoApp extends StatelessWidget {
  const DialogoApp({
    super.key,
    required this.icono,
    required this.titulo,
    this.descripcion,
    this.contenido,
    this.acciones = const [],
    this.colorIcono = AppTheme.darkTeal,
  });

  final IconData icono;
  final String titulo;
  final String? descripcion;
  final Widget? contenido;
  final List<Widget> acciones;
  final Color colorIcono;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardBg,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorIcono == AppTheme.darkTeal
                    ? AppTheme.lightTeal
                    : colorIcono.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 30, color: colorIcono),
            ),
            const SizedBox(height: 14),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.darkTeal,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (descripcion != null) ...[
              const SizedBox(height: 6),
              Text(
                descripcion!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.grey,
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
            ],
            if (contenido != null) ...[const SizedBox(height: 18), contenido!],
            if (acciones.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  for (final (i, a) in acciones.indexed) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: a),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Botón principal de un [DialogoApp] (relleno).
class BotonDialogo extends StatelessWidget {
  const BotonDialogo({
    super.key,
    required this.texto,
    required this.onPressed,
    this.color = AppTheme.darkTeal,
    this.secundario = false,
  });

  /// Botón de cancelar: sin relleno.
  const BotonDialogo.secundario({
    super.key,
    required this.texto,
    required this.onPressed,
  }) : color = AppTheme.darkTeal,
       secundario = true;

  final String texto;
  final VoidCallback? onPressed;
  final Color color;
  final bool secundario;

  @override
  Widget build(BuildContext context) {
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );
    const padding = EdgeInsets.symmetric(vertical: 14);
    const estilo = TextStyle(fontWeight: FontWeight.w800, fontSize: 15);
    if (secundario) {
      return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.darkTeal,
          backgroundColor: AppTheme.bgCream,
          shape: forma,
          padding: padding,
        ),
        child: Text(texto, style: estilo),
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: forma,
        padding: padding,
      ),
      child: Text(texto, style: estilo),
    );
  }
}

/// Estilo de campo de texto de la app: fondo crema, sin borde y verde al enfocar.
InputDecoration decoracionCampo({
  required String hint,
  IconData? icono,
  Widget? sufijo,
  String? etiqueta,
}) {
  final redondeo = BorderRadius.circular(16);
  return InputDecoration(
    hintText: hint,
    labelText: etiqueta,
    labelStyle: const TextStyle(color: AppTheme.grey),
    floatingLabelStyle: const TextStyle(
      color: AppTheme.darkTeal,
      fontWeight: FontWeight.w800,
    ),
    hintStyle: const TextStyle(color: AppTheme.grey),
    prefixIcon: icono == null ? null : Icon(icono, color: AppTheme.darkTeal),
    suffixIcon: sufijo,
    filled: true,
    fillColor: AppTheme.bgCream,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: redondeo,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: redondeo,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: redondeo,
      borderSide: const BorderSide(color: AppTheme.darkTeal, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: redondeo,
      borderSide: const BorderSide(color: AppTheme.tomato, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: redondeo,
      borderSide: const BorderSide(color: AppTheme.tomato, width: 2),
    ),
  );
}
