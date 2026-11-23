import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/features/auth/providers/auth_providers.dart';
import 'package:miapp/features/auth/providers/auth_state.dart';

/// Separador "o continuar con" + botón ancho de Google. Sirve igual para
/// login y registro: con OAuth, si la cuenta no existe Supabase la crea.
class AccesoGoogle extends ConsumerWidget {
  const AccesoGoogle({super.key, this.etiqueta = 'o continuar con'});

  final String etiqueta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cargando = ref.watch(authNotifierProvider) is AuthLoading;
    final estiloLetra = GoogleFonts.poppins(
      fontSize: 22,
      fontWeight: FontWeight.w800,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppTheme.ringBackground)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                etiqueta,
                style: TextStyle(color: AppTheme.grey, fontSize: 14),
              ),
            ),
            Expanded(child: Divider(color: AppTheme.ringBackground)),
          ],
        ),
        const SizedBox(height: 20),
        Material(
          color: AppTheme.bgCream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: cargando
                ? null
                : () =>
                      ref.read(authNotifierProvider.notifier).loginConGoogle(),
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 60,
              child: Center(
                child: Text(
                  'G',
                  style: estiloLetra.copyWith(
                    color: const Color.fromARGB(255, 244, 78, 66),
                    fontSize: 26,
                  ),
                  semanticsLabel: 'Continuar con Google',
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
