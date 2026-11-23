import 'package:miapp/features/perfil/models/usuario_model.dart';

/// Contrato para consultar y actualizar el perfil del usuario.
abstract interface class UsuarioRepository {
  Future<Usuario> obtenerUsuario();

  /// Registra que el usuario practicó [hoy] (fecha local) y devuelve el
  /// perfil con la racha actualizada.
  Future<Usuario> registrarPractica(DateTime hoy);

  /// Envía el resultado de una partida del juego; el backend da XP la primera
  /// vez que se gana cada [modo] y [dificultad] (aparte si es [inverso]).
  /// Devuelve el perfil.
  Future<Usuario> registrarResultadoJuego({
    required String modo,
    required String dificultad,
    required int aciertos,
    required int total,
    bool inverso = false,
  });

  /// Envía los aciertos de una partida de supervivencia; el backend los
  /// guarda como récord si lo superan. Devuelve el perfil.
  Future<Usuario> registrarSupervivencia(int aciertos);

  /// Envía el reto diario de [fecha] (local). Solo cuenta la primera partida
  /// del día: suma a la racha si hubo aciertos y da XP si se ganó.
  Future<Usuario> registrarRetoDiario({
    required DateTime fecha,
    required int aciertos,
    required int total,
  });

  /// Envía el resultado del quiz de un tema de Cultura; el backend da XP la
  /// primera vez que se aprueba cada [tema]. Devuelve el perfil.
  Future<Usuario> registrarQuizCultura({
    required String tema,
    required int aciertos,
    required int total,
  });

  /// Fechas locales (sin hora) en que el usuario practicó.
  Future<Set<DateTime>> obtenerDiasPractica();

  /// Cambia el nombre visible del usuario y devuelve el perfil actualizado.
  Future<Usuario> actualizarNombre(String nombre);
}
