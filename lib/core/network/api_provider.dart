import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/network/api_client.dart';
import 'package:miapp/features/auth/providers/auth_providers.dart';

/// Cliente del backend; toma el JWT de la sesión activa de Supabase Auth.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(supabaseClientProvider).auth);
});
