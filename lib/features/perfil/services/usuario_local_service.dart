import 'package:miapp/features/perfil/models/usuario_model.dart';
import 'package:miapp/features/perfil/services/usuario_repository.dart';

/// Implementación local del perfil del usuario.
class UsuarioLocal implements UsuarioRepository {
  @override
  Future<Usuario> obtenerUsuario() {
    // TODO: definir la fuente local de almacenamiento del perfil.
    throw UnimplementedError('pendiente');
  }

  @override
  Future<void> guardarUsuario(Usuario usuario) {
    // TODO: guardar el usuario en almacenamiento persistente.
    throw UnimplementedError('pendiente');
  }
}
