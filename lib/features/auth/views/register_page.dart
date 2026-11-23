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

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final Color bgColor = const Color(0xFFEEE2CB);
  final Color darkTeal = const Color(0xFF1B4532);
  final Color buttonTeal = const Color(0xFF1B4532);
  final Color coralColor = const Color(0xFFEE4129);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    ref
        .read(authNotifierProvider.notifier)
        .register(
          nombre: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
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
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Crea tu cuenta',
                          style: TextStyle(
                            color: darkTeal,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _fieldLabel('Nombre', textTheme),
                        const SizedBox(height: 8),
                        _textField(
                          _nameController,
                          'Tu nombre',
                          false,
                          icono: Icons.badge_outlined,
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel('Correo electrónico', textTheme),
                        const SizedBox(height: 8),
                        _textField(
                          _emailController,
                          'ana.aprende@gmail.com',
                          false,
                          icono: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel('Contraseña', textTheme),
                        const SizedBox(height: 8),
                        _textField(
                          _passwordController,
                          '••••••••••••',
                          _obscurePassword,
                          icono: Icons.lock_outline_rounded,
                          suffixAction: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel('Confirmar contraseña', textTheme),
                        const SizedBox(height: 8),
                        _textField(
                          _confirmPasswordController,
                          '••••••••••••',
                          _obscureConfirmPassword,
                          icono: Icons.lock_reset_rounded,
                          suffixAction: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 55,
                          child: ElevatedButton(
                            onPressed: authState is AuthLoading
                                ? null
                                : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: authState is AuthLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Registrarme',
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
                        const AccesoGoogle(etiqueta: 'o regístrate con'),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => context.go(RouteNames.loginPath),
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
                                    text: '¿Ya tienes una cuenta? ',
                                  ),
                                  TextSpan(
                                    text: 'Inicia sesión',
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

  Widget _fieldLabel(String text, TextTheme textTheme) {
    return Text(
      text,
      style:
          textTheme.labelLarge?.copyWith(
            color: darkTeal,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ) ??
          TextStyle(color: darkTeal, fontWeight: FontWeight.w700, fontSize: 14),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String hint,
    bool obscure, {
    required IconData icono,
    VoidCallback? suffixAction,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: decoracionCampo(
        hint: hint,
        icono: icono,
        sufijo: suffixAction == null
            ? null
            : IconButton(
                tooltip: obscure ? 'Mostrar' : 'Ocultar',
                onPressed: suffixAction,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.grey,
                ),
              ),
      ),
    );
  }
}
