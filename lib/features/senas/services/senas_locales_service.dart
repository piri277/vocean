import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:miapp/core/utils/json_utils.dart';
import 'package:miapp/features/senas/models/estado_aprendizaje_model.dart';
import 'package:miapp/features/senas/models/sena_model.dart';
import 'package:miapp/features/senas/services/senas_repository.dart';

/// Cómo se lee un archivo de texto. Se inyecta para poder probar sin assets.
typedef LectorDeAssets = Future<String> Function(String ruta);

class SenasLocales implements SenasRepository {
  /// El lector entra por el constructor. En producción es `rootBundle`; en
  /// las pruebas, una función que devuelve una cadena. Esa costura de dos
  /// líneas es lo que hace que las pruebas no necesiten ni Flutter ni el
  /// bundle.
  SenasLocales({LectorDeAssets? lector, this.ruta = 'assets/data/senas.json'})
    : _lector = lector ?? rootBundle.loadString;

  final LectorDeAssets _lector;
  final String ruta;

  /// El archivo no cambia mientras la app corre: leerlo y parsearlo en cada
  /// pantalla sería tirar trabajo a la basura.
  List<Sena>? _cache;

  @override
  Future<List<Sena>> obtenerTodas() async {
    final guardado = _cache;
    if (guardado != null) return guardado;

    final crudo = await _lector(ruta);
    final decodificado = jsonDecode(crudo);

    if (decodificado is! List) {
      throw const CampoInvalido(
        '(raíz)',
        'el archivo debe contener una lista',
        null,
      );
    }

    return _cache = decodificado
        .map((e) => Sena.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Sena?> obtenerPorId(String id) async {
    // firstWhere sin orElse lanza `Bad state: No element` cuando no encuentra.
    // Un bucle explícito devuelve null y se lee mejor que el orElse con truco.
    for (final sena in await obtenerTodas()) {
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
