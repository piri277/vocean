import 'package:miapp/features/perfil/models/usuario_model.dart';
import 'package:miapp/features/perfil/services/usuario_repository.dart';

/// Repositorio de usuario en memoria: guarda lo que la app le envía.
class RepoUsuarioFalso implements UsuarioRepository {
  final quizzes = <(String, int, int)>[];
  final _usuario = Usuario(
    xpTotal: 0,
    partidasJugadas: 0,
    rachaGlobalMaxima: 0,
    fechaUltimaActividad: DateTime(2026),
  );

  @override
  Future<Usuario> registrarQuizCultura({
    required String tema,
    required int aciertos,
    required int total,
  }) async {
    quizzes.add((tema, aciertos, total));
    return _usuario.copyWith(xpTotal: 15);
  }

  @override
  Future<Usuario> obtenerUsuario() async => _usuario;
  @override
  Future<Usuario> registrarPractica(DateTime hoy) async => _usuario;
  @override
  Future<Usuario> registrarResultadoJuego({
    required String modo,
    required String dificultad,
    required int aciertos,
    required int total,
    bool inverso = false,
  }) async => _usuario;
  final supervivencias = <int>[];

  @override
  Future<Usuario> registrarSupervivencia(int aciertos) async {
    supervivencias.add(aciertos);
    return _usuario;
  }

  final retos = <(DateTime, int, int)>[];

  @override
  Future<Usuario> registrarRetoDiario({
    required DateTime fecha,
    required int aciertos,
    required int total,
  }) async {
    retos.add((fecha, aciertos, total));
    return _usuario;
  }

  @override
  Future<Set<DateTime>> obtenerDiasPractica() async => {};
  @override
  Future<Usuario> actualizarNombre(String nombre) async => _usuario;
}
