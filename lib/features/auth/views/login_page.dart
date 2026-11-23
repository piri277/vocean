import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:miapp/core/theme/app_theme.dart';
import 'package:miapp/core/widgets/dialogo_app.dart';
import 'package:miapp/core/router/route_names.dart';
import 'package:miapp/features/auth/providers/auth_providers.dart';
import 'package:miapp/features/auth/providers/auth_state.dart';
import 'package:miapp/features/auth/widgets/acceso_google.dart';
import 'package:miapp/features/auth/widgets/ocean_background.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  final Color bgColor = const Color(0xFFEEE2CB);
  final Color darkTeal = const Color(0xFF1B4532);
  final Color buttonTeal = const Color(0xFF1B4532);
  final Color lightTealBg = const Color(0xFFDDE2CC);
  final Color coralColor = const Color(0xFFEE4129);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    ref
        .read(authNotifierProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        context.go(RouteNames.homePath);
      } else if (next is AuthError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    final textTheme = GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: bgColor,
      body: OceanBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.darkTeal.withValues(alpha: 0.3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        // Mismo dibujo que el ícono de la app en el teléfono.
                        child: Image.asset(
                          'assets/branding/icono_app.png',
                          semanticLabel: 'Logo de VOCEAN',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VOCEAN',
                              style: GoogleFonts.poppins(
                                color: darkTeal,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const Text(
                              'Aprende Lengua de Señas Colombiana',
                              style: TextStyle(
                                color: AppTheme.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.darkTeal.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '¡Hola de nuevo!',
                          style: TextStyle(
                            color: darkTeal,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Correo electrónico',
                          style:
                              textTheme.labelLarge?.copyWith(
                                color: darkTeal,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ) ??
                              TextStyle(
                                color: darkTeal,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: decoracionCampo(
                            hint: 'ana.aprende@gmail.com',
                            icono: Icons.alternate_email_rounded,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Contraseña',
                          style:
                              textTheme.labelLarge?.copyWith(
                                color: darkTeal,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ) ??
                              TextStyle(
                                color: darkTeal,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: decoracionCampo(
                            hint: '••••••••••••',
                            icono: Icons.lock_outline_rounded,
                            sufijo: IconButton(
                              tooltip: _obscurePassword ? 'Mostrar' : 'Ocultar',
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppTheme.grey,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              '¿Olvidaste tu contraseña?',
                              style:
                                  textTheme.bodyMedium?.copyWith(
                                    color: buttonTeal,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: buttonTeal,
                                  ) ??
                                  TextStyle(
                                    color: buttonTeal,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: buttonTeal,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: authState is AuthLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                            ),
                            child: authState is AuthLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Iniciar sesión',
                                    style:
                                        textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ) ??
                                        const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const AccesoGoogle(),
                        const SizedBox(height: 18),
                        Center(
                          child: TextButton(
                            onPressed: () =>
                                context.go(RouteNames.registerPath),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: RichText(
                              text: TextSpan(
                                style:
                                    textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.grey,
                                      fontSize: 15,
                                    ) ??
                                    TextStyle(
                                      color: AppTheme.grey,
                                      fontSize: 15,
                                    ),
                                children: [
                                  const TextSpan(
                                    text: '¿Aún no tienes una cuenta? ',
                                  ),
                                  TextSpan(
                                    text: 'Crea una cuenta gratis',
                                    style: TextStyle(
                                      color: coralColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
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
        ),
      ),
    );
  }
}
