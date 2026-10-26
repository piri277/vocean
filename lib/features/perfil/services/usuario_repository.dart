import 'package:miapp/features/perfil/models/usuario_model.dart';

/// Contrato para consultar y actualizar el perfil del usuario.
abstract interface class UsuarioRepository {
  Future<Usuario> obtenerUsuario();

  /// Registra que el usuario practicó [hoy] (fecha local) y devuelve el
  /// perfil con la racha actualizada.
  Future<Usuario> registrarPractica(DateTime hoy);
}
