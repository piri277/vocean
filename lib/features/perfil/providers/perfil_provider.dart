import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miapp/core/network/api_provider.dart';
import 'package:miapp/features/perfil/models/usuario_model.dart';
import 'package:miapp/features/perfil/services/api_usuario_repository.dart';
import 'package:miapp/features/perfil/services/usuario_repository.dart';

/// Provider que expone la implementación de [UsuarioRepository].
final usuarioRepositoryProvider = Provider<UsuarioRepository>((ref) {
  return ApiUsuarioRepository(ref.watch(apiClientProvider));
});

/// FutureProvider que consulta el perfil del usuario actual desde el backend.
final usuarioFutureProvider = FutureProvider<Usuario>((ref) async {
  final repo = ref.watch(usuarioRepositoryProvider);
  return repo.obtenerUsuario();
});

/// Días practicados (historial del calendario de racha).
final diasPracticaProvider = FutureProvider<Set<DateTime>>((ref) {
  return ref.watch(usuarioRepositoryProvider).obtenerDiasPractica();
});

/// Provider síncrono que expone los datos del usuario cargado.
final usuarioProvider = Provider<Usuario?>((ref) {
  return ref.watch(usuarioFutureProvider).value;
});
