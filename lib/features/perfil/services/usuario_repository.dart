import 'package:miapp/features/perfil/models/usuario_model.dart';

/// Contrato para consultar y actualizar el perfil del usuario.
abstract interface class UsuarioRepository {
  Future<Usuario> obtenerUsuario();

  /// Registra que el usuario practicó [hoy] (fecha local) y devuelve el
  /// perfil con la racha actualizada.
  Future<Usuario> registrarPractica(DateTime hoy);

  /// Envía el resultado de una partida del juego; el backend da XP la primera
  /// vez que se gana cada [modo] y [dificultad]. Devuelve el perfil.
  Future<Usuario> registrarResultadoJuego({
    required String modo,
    required String dificultad,
    required int aciertos,
    required int total,
  });

  /// Fechas locales (sin hora) en que el usuario practicó.
  Future<Set<DateTime>> obtenerDiasPractica();

  /// Cambia el nombre visible del usuario y devuelve el perfil actualizado.
  Future<Usuario> actualizarNombre(String nombre);
}
