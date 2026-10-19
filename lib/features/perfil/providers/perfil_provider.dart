import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/features/auth/providers/auth_providers.dart';
import 'package:miapp/features/perfil/models/usuario_model.dart';
import 'package:miapp/features/perfil/services/supabase_usuario_repository.dart';
import 'package:miapp/features/perfil/services/usuario_repository.dart';

/// Provider que expone la implementación de [UsuarioRepository].
final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseUsuarioRepository(client);
});

/// FutureProvider que consulta el perfil del usuario actual desde Supabase.
final usuarioFutureProvider = FutureProvider<Usuario>((ref) async {
  final repo = ref.watch(usuarioRepositoryProvider);
  return repo.obtenerUsuario();
});

/// Provider síncrono que expone los datos del usuario cargado.
final usuarioProvider = Provider<Usuario?>((ref) {
  return ref.watch(usuarioFutureProvider).value;
});
