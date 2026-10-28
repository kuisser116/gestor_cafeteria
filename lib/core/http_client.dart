import 'dart:async';
import 'dart:convert';
 
import 'package:flutter/foundation.dart';
import 'package:gestor_cafeteria/core/failure.dart';
import 'package:gestor_cafeteria/core/token_storage.dart';
import 'package:http/http.dart' as http;
 
class ApiClient {
  final http.Client? _client;
  final Uri? baseUrl;
  final Duration timeout;
  final TokenStorage? _tokens;
  //Clase Client
  ApiClient({
    http.Client? client,
    String? baseUrl,
    TokenStorage? tokenStorage,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client(),
       _tokens = tokenStorage,
       baseUrl = _validated(
         baseUrl ??
             (const String.fromEnvironment('API_URL').isNotEmpty
                 ? const String.fromEnvironment('API_URL')
                 : (kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000')),
       );
 
  // http:// solo se acepta hacia el equipo de desarrollo; todo lo demás, https.
  static const _hostsLocales = {'localhost', '127.0.0.1', '10.0.2.2'};
 
  static Uri _validated(String raw) {
    final uri = Uri.parse(raw);
    if (uri.scheme == 'https') return uri;
    if (uri.scheme == 'http' && _hostsLocales.contains(uri.host)) return uri;
    throw ArgumentError.value(
      raw,
      'baseUrl',
      'Se exige https fuera de desarrollo local',
    );
  }
 
  //POST,GET,PATCH,DELETE
  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, Object body) => _send('POST', path, body);
  Future<dynamic> patch(String path, Object body) => _send('PATCH', path, body);
  Future<dynamic> update(String path, Object body) =>
      _send('UPDATE', path, body);
  Future<void> delete(String path) => _send('DELETE', path);
 
  //Funcion SEND -> Mandar la peticion al Servicio, esperar una respuesta y adecuarlo para flutter
 
  Future<dynamic> _send(String method, String path, [Object? body]) async {
    //Request: Va arma la peticion con la inyeccion de los HEADERS
    final request = http.Request(method, baseUrl!.resolve(path))
      ..headers['Accept'] = 'application/json';
    final token = await _tokens?.read();
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    //Si es una peticion que tiene que mandar un body
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    //Guardar la respuesta del servicio
    final http.Response response;
    //El response se va a tratar segun el caso con el servicio respondio
    try {
      response = await _client!
          .send(request)
          .then(http.Response.fromStream)
          .timeout(timeout);
    } on http.ClientException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    }
    final json = _tryDecode(response);
    final code = response.statusCode;
    if (code == 401) {
      await _tokens?.clear();
      throw const UnauthorizedFailure();
    }
    if (code >= 200 && code < 300) {
      return json;
    } else {
      throw mapHttpError(code, json);
    }
  }
 
  dynamic _tryDecode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
 
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
  }
 
  //Direccionamiento de los errores fuera de los 200's y los 300's
  // 404 -> NotFoundFailure, 409 -> ConflictFailure, 422 -> ValidationFailure,
  // 500..599 -> ServerFailure y cualquier otro -> UnexpectedFailure,
  // usando el campo `detail` que trae el servidor cuando existe.
  Failure mapHttpError(int code, Object? json) {
    return switch (code) {
      404 => NotFoundFailure(_detailMessage(json, 'Orden no encontrada')),
      409 => ConflictFailure(_detailMessage(json, 'Acción no permitida')),
      422 => ValidationFailure(_fieldsFrom(json)),
      >= 500 && < 600 => ServerFailure(code),
      _ => UnexpectedFailure(
          code, _detailMessage(json, 'Error desconocido ($code)')),
    };
  }
 
  //`detail` es texto en 404, 409 y en los errores simulados; si no lo es,
  //se usa el mensaje de respaldo para no romperse con null u otros formatos.
  String _detailMessage(Object? json, String fallback) {
    if (json is Map && json['detail'] is String) {
      return json['detail'] as String;
    }
    return fallback;
  }
 
  //En 422 `detail` es una lista de errores; por cada elemento la clave del
  //mapa es loc[1] (p. ej. "customer") y el valor es msg.
  Map<String, String> _fieldsFrom(Object? json) {
    final fields = <String, String>{};
    if (json is Map && json['detail'] is List) {
      for (final error in json['detail'] as List) {
        if (error is Map && error['loc'] is List && error['msg'] is String) {
          final loc = error['loc'] as List;
          if (loc.isNotEmpty) {
            final key = loc.length > 1 ? loc[1] : loc.last;
            fields[key.toString()] = error['msg'] as String;
          }
        }
      }
    }
    return fields;
  }
}
