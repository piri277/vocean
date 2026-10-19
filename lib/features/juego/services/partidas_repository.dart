import 'package:miapp/features/juego/models/partida_model.dart';

/// Contrato para persistir partidas.
abstract interface class PartidasRepository {
  Future<void> guardarPartida(Partida partida);

  Future<List<Partida>> obtenerHistorial();
}
