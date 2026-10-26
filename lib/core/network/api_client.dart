import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Error de una llamada al backend con código HTTP distinto de 2xx.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.mensaje);

  final int statusCode;
  final String mensaje;

  @override
  String toString() => 'ApiException($statusCode): $mensaje';
}

/// Cliente HTTP del backend FastAPI.
///
/// Supabase solo se usa para la sesión: cada petición lleva el JWT del usuario
/// en `Authorization`, y el backend lo valida y aplica RLS con él.
class ApiClient {
  ApiClient(this._auth, {http.Client? cliente, String? baseUrl})
    : _http = cliente ?? http.Client(),
      _baseUrl = baseUrl ?? defaultBaseUrl;

  /// Se configura al compilar: `--dart-define=API_URL=http://<ip>:8000/api`.
  /// Por defecto usa localhost, que llega al backend del PC tras
  /// `adb reverse tcp:8000 tcp:8000` (teléfono por USB o emulador).
  static const defaultBaseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  static const _timeout = Duration(seconds: 10);

  final GoTrueClient _auth;
  final http.Client _http;
  final String _baseUrl;

  bool get haySesion => _auth.currentSession != null;

  Future<dynamic> get(String ruta, {Map<String, String>? query}) =>
      _enviar((uri, headers) => _http.get(uri, headers: headers), ruta, query);

  Future<dynamic> post(String ruta, Object cuerpo) => _enviar(
    (uri, headers) =>
        _http.post(uri, headers: headers, body: jsonEncode(cuerpo)),
    ruta,
    null,
  );

  Future<dynamic> _enviar(
    Future<http.Response> Function(Uri, Map<String, String>) peticion,
    String ruta,
    Map<String, String>? query,
  ) async {
    final token = _auth.currentSession?.accessToken;
    final respuesta = await peticion(
      Uri.parse('$_baseUrl$ruta').replace(queryParameters: query),
      {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    ).timeout(_timeout);

    final cuerpo = utf8.decode(respuesta.bodyBytes);
    if (respuesta.statusCode < 200 || respuesta.statusCode >= 300) {
      throw ApiException(respuesta.statusCode, cuerpo);
    }
    return cuerpo.isEmpty ? null : jsonDecode(cuerpo);
  }
}
