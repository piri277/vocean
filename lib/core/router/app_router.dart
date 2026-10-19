import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:miapp/core/router/route_names.dart';
import 'package:miapp/features/home/views/home_page.dart';
import 'package:miapp/features/auth/views/login_page.dart';
import 'package:miapp/features/auth/views/register_page.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.loginPath,
  // Con sesión activa se salta login/registro; sin sesión no se entra a home.
  redirect: (context, state) {
    // Supabase puede no estar inicializado (p. ej. en tests): sin sesión.
    var logueado = false;
    try {
      logueado = Supabase.instance.client.auth.currentSession != null;
    } catch (_) {}
    final enAuth = state.matchedLocation == RouteNames.loginPath ||
        state.matchedLocation == RouteNames.registerPath;
    if (logueado && enAuth) return RouteNames.homePath;
    if (!logueado && !enAuth) return RouteNames.loginPath;
    return null;
  },
  routes: [
    GoRoute(
      path: RouteNames.loginPath,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: RouteNames.registerPath,
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: RouteNames.homePath,
      builder: (context, state) => const HomePage(),
    ),
  ],
);
