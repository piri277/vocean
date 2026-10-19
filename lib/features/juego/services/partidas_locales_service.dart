import 'package:miapp/features/juego/models/partida_model.dart';
import 'package:miapp/features/juego/services/partidas_repository.dart';

/// Implementación local de almacenamiento de partidas.
class PartidasLocales implements PartidasRepository {
  @override
  Future<void> guardarPartida(Partida partida) {
    // TODO: decidir el backend local (SharedPreferences o Hive) y guardar.
    throw UnimplementedError('pendiente');
  }

  @override
  Future<List<Partida>> obtenerHistorial() {
    // TODO: cargar el historial guardado localmente.
    throw UnimplementedError('pendiente');
  }
}
