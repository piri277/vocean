import 'package:miapp/features/perfil/models/usuario_model.dart';

/// Contrato para persistir el perfil del usuario.
abstract interface class UsuarioRepository {
  Future<Usuario> obtenerUsuario();

  Future<void> guardarUsuario(Usuario usuario);
}
