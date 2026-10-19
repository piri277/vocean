import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/models/posicion_mano_model.dart';
import 'package:miapp/features/senas/models/sena_model.dart';
import 'package:miapp/features/senas/services/senas_locales_service.dart';
import 'package:miapp/features/senas/services/senas_repository.dart';

/// Implementación de [SenasRepository] conectada directamente a Supabase PostgreSQL.
///
/// Obtiene el catálogo global de señas con sus posiciones de referencia anatómicas
/// y las combina de forma transparente con el estado de aprendizaje del usuario actual.
/// En caso de pérdida de conexión, cuenta con fallback a los assets locales.
class SupabaseSenasRepository implements SenasRepository {
  SupabaseSenasRepository(this._client, {SenasRepository? fallback})
    : _fallback = fallback ?? SenasLocales();

  final SupabaseClient _client;
  final SenasRepository _fallback;

  List<Sena>? _cache;

  @override
  Future<List<Sena>> obtenerTodas() async {
    final cached = _cache;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      final rows = await _client
          .from('sena')
          .select('*, posicion_referencia(*)')
          .order('nombre');

      final user = _client.auth.currentUser;
      final progresoMap = <String, Map<String, dynamic>>{};

      if (user != null) {
        try {
          final progresoRows = await _client
              .from('estado_aprendizaje')
              .select()
              .eq('usuario_id', user.id);

          for (final row in progresoRows) {
            final sId = row['sena_id'] as String?;
            if (sId != null) {
              progresoMap[sId] = row;
            }
          }
        } catch (e) {
          debugPrint('Error al consultar progreso del usuario: $e');
        }
      }

      final lista = <Sena>[];
      for (final item in (rows as List)) {
        final id = item['id'] as String;
        final nombre = item['nombre'] as String;
        final categoria = item['categoria'] as String;
        final descripcion = item['descripcion'] as String;
        final videoReferencia = item['video_referencia'] as String?;

        // Mapear posición de referencia anatómica
        final posData = item['posicion_referencia'];
        final posMap = (posData is List && posData.isNotEmpty)
            ? posData.first as Map<String, dynamic>
            : (posData is Map<String, dynamic> ? posData : null);

        final posicion = posMap != null
            ? PosicionMano(
                landmarksClave:
                    (posMap['landmarks_clave'] as List?)
                        ?.map((e) => (e as num).toInt())
                        .toList() ??
                    const [],
                anguloPulgar:
                    (posMap['angulo_pulgar'] as num?)?.toDouble() ?? 0.0,
                distanciaIndiceMedio:
                    (posMap['distancia_indice_medio'] as num?)?.toDouble() ??
                    0.0,
              )
            : const PosicionMano(
                landmarksClave: [],
                anguloPulgar: 0.0,
                distanciaIndiceMedio: 0.0,
              );

        // Mapear progreso personal del usuario
        final p = progresoMap[id];
        final EstadoAprendizaje estado;
        if (p != null) {
          final tipo = p['tipo'] as String?;
          if (tipo == 'dominada') {
            estado = Dominada(
              DateTime.tryParse(p['fecha_dominada']?.toString() ?? '') ??
                  DateTime.now(),
              (p['precision'] as num?)?.toDouble() ?? 1.0,
            );
          } else if (tipo == 'en_practica') {
            estado = EnPractica(
              (p['intentos'] as num?)?.toInt() ?? 1,
              DateTime.tryParse(p['ultimo_intento']?.toString() ?? '') ??
                  DateTime.now(),
            );
          } else if (tipo == 'necesita_repaso') {
            estado = NecesitaRepaso(
              p['motivo'] as String? ?? 'Repaso pendiente',
              (p['dias_sin_practicar'] as num?)?.toInt() ?? 1,
            );
          } else {
            estado = const NoIniciada();
          }
        } else {
          estado = const NoIniciada();
        }

        lista.add(
          Sena(
            id: id,
            nombre: nombre,
            categoria: categoria,
            descripcion: descripcion,
            posicionReferencia: posicion,
            estadoAprendizaje: estado,
            imagenReferencia: videoReferencia,
          ),
        );
      }

      _cache = lista;
      return lista;
    } catch (e) {
      debugPrint('Fallo al obtener señas desde Supabase: $e. Usando fallback.');
      return _fallback.obtenerTodas();
    }
  }

  @override
  Future<Sena?> obtenerPorId(String id) async {
    final todas = await obtenerTodas();
    for (final sena in todas) {
      if (sena.id == id) return sena;
    }
    return null;
  }

  @override
  Future<List<Sena>> obtenerPendientes() async {
    final todas = await obtenerTodas();
    return todas
        .where(
          (sena) =>
              sena.estadoAprendizaje is NoIniciada || sena.requierePractica,
        )
        .toList(growable: false);
  }
}
