import "dart:convert";
 
import 'package:gestor_cafeteria/core/failure.dart';
import 'package:gestor_cafeteria/core/http_client.dart';
import 'package:gestor_cafeteria/core/token_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';
 
ApiClient clienteQueResponde(int status, [Object? body]) {
  return ApiClient(
    baseUrl: 'https://test',
    client: MockClient(
      (request) async => http.Response(
        body == null ? '' : jsonEncode(body),
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    ),
  );
}
 
void main() {
  //Hacer el agrupamiento de pruebas
  group('Probar los Codigos de error', () {
    test('404 -> NotFoundFailure()', () async {
      final api = clienteQueResponde(404, {'detail': 'Order 999 not found'});
      await expectLater(
        api.get('/orders/999'),
        throwsA(isA<NotFoundFailure>()),
      );
    });
  });
 
  group('Transporte: guardia de baseUrl', () {
    test('http:// hacia un host remoto -> ArgumentError', () {
      expect(
        () => ApiClient(baseUrl: 'http://api.cafeteria.com'),
        throwsArgumentError,
      );
    });
 
    test('http:// hacia el emulador y https:// remoto -> permitidos', () {
      expect(() => ApiClient(baseUrl: 'http://10.0.2.2:8000'), returnsNormally);
      expect(
        () => ApiClient(baseUrl: 'https://api.cafeteria.com'),
        returnsNormally,
      );
    });
  });
 
  group('Token seguro', () {
    test('con token guardado manda Authorization: Bearer', () async {
      String? visto;
      final api = ApiClient(
        baseUrl: 'https://test',
        tokenStorage: InMemoryTokenStorage('abc123'),
        client: MockClient((request) async {
          visto = request.headers['Authorization'];
          return http.Response('{}', 200);
        }),
      );
      await api.get('/orders');
      expect(visto, 'Bearer abc123');
    });
 
    test('sin token no manda Authorization', () async {
      bool? tieneHeader;
      final api = ApiClient(
        baseUrl: 'https://test',
        tokenStorage: InMemoryTokenStorage(),
        client: MockClient((request) async {
          tieneHeader = request.headers.containsKey('Authorization');
          return http.Response('{}', 200);
        }),
      );
      await api.get('/orders');
      expect(tieneHeader, isFalse);
    });
 
    test('401 borra el token y lanza UnauthorizedFailure', () async {
      final storage = InMemoryTokenStorage('vencido');
      final api = ApiClient(
        baseUrl: 'https://test',
        tokenStorage: storage,
        client: MockClient((request) async => http.Response('', 401)),
      );
      await expectLater(
        api.get('/orders'),
        throwsA(isA<UnauthorizedFailure>()),
      );
      expect(await storage.read(), isNull);
    });
  });
}
