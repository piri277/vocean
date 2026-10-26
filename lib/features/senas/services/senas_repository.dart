import 'package:miapp/features/senas/models/sena_model.dart';

/// Lo que la aplicación necesita saber de las señas.
///
/// `abstract interface class` = solo contrato: nadie puede heredar de aquí,
/// solo implementarlo. Es la declaración de intenciones más explícita que hay.
abstract interface class SenasRepository {
  Future<List<Sena>> obtenerTodas();

  Future<Sena?> obtenerPorId(String id);

  /// Método propio del dominio: las señas que el usuario debería practicar
  /// hoy (en práctica, necesitan repaso, o nunca las ha intentado).
  Future<List<Sena>> obtenerPendientes();

  /// Registra que el usuario practicó [senaId] el día [hoy] (fecha local).
  /// Sin [acierto] solo la marca en práctica; con [acierto] cuenta el día para
  /// dominarla y [precision] es la confianza del reconocimiento.
  Future<void> registrarPractica(
    String senaId,
    DateTime hoy, {
    bool acierto = false,
    double? precision,
  });
}
