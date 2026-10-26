import 'package:flutter/foundation.dart';
import 'package:miapp/core/network/api_client.dart';
import 'package:miapp/features/perfil/models/usuario_model.dart';
import 'package:miapp/features/perfil/services/usuario_repository.dart';

/// Implementación de [UsuarioRepository] sobre el backend (`/usuarios/me`).
///
/// El backend crea la fila del perfil si aún no existe.
class ApiUsuarioRepository implements UsuarioRepository {
  ApiUsuarioRepository(this._api);

  final ApiClient _api;

  @override
  Future<Usuario> obtenerUsuario() async {
    if (!_api.haySesion) return _vacio();
    try {
      return _desdeJson(await _api.get('/usuarios/me') as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Error al obtener el usuario del backend: $e');
      return _vacio();
    }
  }

  @override
  Future<Usuario> registrarPractica(DateTime hoy) async {
    final fecha = hoy.toIso8601String().substring(0, 10);
    final json = await _api.post('/usuarios/me/practica', {'fecha': fecha});
    return _desdeJson(json as Map<String, dynamic>);
  }

  static Usuario _vacio() => Usuario(
    xpTotal: 0,
    partidasJugadas: 0,
    rachaGlobalMaxima: 0,
    fechaUltimaActividad: DateTime.now(),
  );

  static Usuario _desdeJson(Map<String, dynamic> json) => Usuario(
    xpTotal: (json['xp_total'] as num?)?.toInt() ?? 0,
    partidasJugadas: (json['partidas_jugadas'] as num?)?.toInt() ?? 0,
    rachaGlobalMaxima: (json['racha_global_maxima'] as num?)?.toInt() ?? 0,
    fechaUltimaActividad:
        DateTime.tryParse(json['fecha_ultima_actividad']?.toString() ?? '') ??
        DateTime.now(),
    nombre: json['nombre'] as String?,
    rachaDias: (json['racha_dias'] as num?)?.toInt() ?? 0,
    ultimaPractica: DateTime.tryParse(
      json['ultima_practica']?.toString() ?? '',
    ),
  );
}
