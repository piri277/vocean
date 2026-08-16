import 'package:miapp/features/senas/domain/sena.dart';

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
}
