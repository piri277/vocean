import 'package:flutter/foundation.dart';
import 'package:miapp/core/network/api_client.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/models/posicion_mano_model.dart';
import 'package:miapp/features/senas/models/sena_model.dart';
import 'package:miapp/features/senas/services/senas_locales_service.dart';
import 'package:miapp/features/senas/services/senas_repository.dart';

/// Implementación de [SenasRepository] sobre el backend (`/senas` y `/progreso`).
///
/// Obtiene el catálogo global de señas con sus posiciones de referencia anatómicas
/// y las combina con el estado de aprendizaje del usuario actual.
/// En caso de pérdida de conexión, cuenta con fallback a los assets locales.
class ApiSenasRepository implements SenasRepository {
  ApiSenasRepository(this._api, {SenasRepository? fallback})
    : _fallback = fallback ?? SenasLocales();

  final ApiClient _api;
  final SenasRepository _fallback;

  List<Sena>? _cache;

  @override
  Future<List<Sena>> obtenerTodas() async {
    final cached = _cache;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }

    try {
      final rows = await _api.get('/senas', query: {'limite': '500'});
      final progresoMap = <String, Map<String, dynamic>>{};

      if (_api.haySesion) {
        try {
          final progresoRows = await _api.get('/progreso') as List;

          for (final row in progresoRows.cast<Map<String, dynamic>>()) {
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
        final posMap = item['posicion_referencia'] as Map<String, dynamic>?;

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
      debugPrint('Fallo al obtener señas del backend: $e. Usando fallback.');
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

  @override
  Future<void> registrarPractica(
    String senaId,
    DateTime hoy, {
    bool acierto = false,
    double? precision,
  }) async {
    await _api.post('/progreso/$senaId/practica', {
      'fecha': hoy.toIso8601String().substring(0, 10),
      'acierto': acierto,
      'precision': ?precision,
    });
    // El estado cambió: la próxima lectura vuelve a pedirlo al backend.
    _cache = null;
  }
}
