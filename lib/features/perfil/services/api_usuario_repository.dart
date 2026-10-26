import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:miapp/features/perfil/models/usuario_model.dart';
import 'package:miapp/features/perfil/services/usuario_repository.dart';

/// Implementación de [UsuarioRepository] conectada a la tabla `usuario` de Supabase.
class SupabaseUsuarioRepository implements UsuarioRepository {
  SupabaseUsuarioRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Usuario> obtenerUsuario() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return Usuario(
        xpTotal: 0,
        partidasJugadas: 0,
        rachaGlobalMaxima: 0,
        fechaUltimaActividad: DateTime.now(),
      );
    }

    try {
      final res = await _client
          .from('usuario')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (res != null) {
        return Usuario(
          xpTotal: (res['xp_total'] as num?)?.toInt() ?? 0,
          partidasJugadas: (res['partidas_jugadas'] as num?)?.toInt() ?? 0,
          rachaGlobalMaxima:
              (res['racha_global_maxima'] as num?)?.toInt() ?? 0,
          fechaUltimaActividad: DateTime.tryParse(
                res['fecha_ultima_actividad']?.toString() ?? '',
              ) ??
              DateTime.now(),
          nombre: res['nombre'] as String?,
        );
      }

      // Si no existe, crear la fila del perfil inicial
      final nombre = user.userMetadata?['nombre'] ??
          user.email?.split('@').first ??
          'Usuario';
      final nuevo = {
        'id': user.id,
        'nombre': nombre,
        'correo': user.email,
        'xp_total': 0,
        'partidas_jugadas': 0,
        'racha_global_maxima': 0,
        'fecha_ultima_actividad': DateTime.now().toIso8601String(),
      };
      await _client.from('usuario').insert(nuevo);

      return Usuario(
        xpTotal: 0,
        partidasJugadas: 0,
        rachaGlobalMaxima: 0,
        fechaUltimaActividad: DateTime.now(),
        nombre: nombre.toString(),
      );
    } catch (e) {
      debugPrint('Error al obtener usuario de Supabase: $e');
      return Usuario(
        xpTotal: 0,
        partidasJugadas: 0,
        rachaGlobalMaxima: 0,
        fechaUltimaActividad: DateTime.now(),
      );
    }
  }

  @override
  Future<void> guardarUsuario(Usuario usuario) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from('usuario').update({
      'xp_total': usuario.xpTotal,
      'partidas_jugadas': usuario.partidasJugadas,
      'racha_global_maxima': usuario.rachaGlobalMaxima,
      'fecha_ultima_actividad': usuario.fechaUltimaActividad.toIso8601String(),
    }).eq('id', user.id);
  }
}

