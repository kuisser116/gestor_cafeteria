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

  // Tarea 1 · una prueba por escenario, cada una con su propio MockClient.
  // Ninguna usa la red: el cliente falso solo devuelve lo que le pedimos.
  group('Tarea 1 · escenarios del cliente con MockClient', () {
    test('éxito: responde 200 con JSON válido y devuelve el JSON decodificado',
        () async {
      final mock = MockClient((request) async {
        return http.Response('[{"id": 1}]', 200);
      });
      final api = ApiClient(client: mock, baseUrl: 'https://prueba');

      final resultado = await api.get('/orders');

      expect(resultado, isA<List>());
      expect(resultado, [
        {'id': 1}
      ]);
    });

    test('no encontrado: 404 lanza NotFoundFailure con el detail del servidor',
        () async {
      final mock = MockClient((request) async {
        return http.Response('{"detail": "Order 9 not found"}', 404,
            headers: {'content-type': 'application/json'});
      });
      final api = ApiClient(client: mock, baseUrl: 'https://prueba');

      await expectLater(
        api.get('/orders/9'),
        throwsA(isA<NotFoundFailure>()
            .having((f) => f.message, 'message', 'Order 9 not found')),
      );
    });

    test('conflicto: 409 lanza ConflictFailure con el detail del servidor',
        () async {
      final mock = MockClient((request) async {
        return http.Response(
            '{"detail": "Cannot change status from pending to delivered"}',
            409,
            headers: {'content-type': 'application/json'});
      });
      final api = ApiClient(client: mock, baseUrl: 'https://prueba');

      await expectLater(
        api.patch('/orders/1', {'status': 'delivered'}),
        throwsA(
            isA<ConflictFailure>().having(
                (f) => f.message,
                'message',
                'Cannot change status from pending to delivered')),
      );
    });

    test(
        'validación: 422 lanza ValidationFailure con fields {customer: Must be 1-50 characters}',
        () async {
      final mock = MockClient((request) async {
        return http.Response(
            '{"detail": [{"loc": ["body", "customer"], "msg": "Must be 1-50 characters"}]}',
            422,
            headers: {'content-type': 'application/json'});
      });
      final api = ApiClient(client: mock, baseUrl: 'https://prueba');

      await expectLater(
        api.post('/orders', {'customer': ''}),
        throwsA(isA<ValidationFailure>().having(
            (f) => f.fields['customer'],
            'fields[customer]',
            'Must be 1-50 characters')),
      );
    });

    test('servidor: 503 lanza ServerFailure con statusCode 503', () async {
      final mock = MockClient((request) async {
        return http.Response('{"detail": "boom"}', 503,
            headers: {'content-type': 'application/json'});
      });
      final api = ApiClient(client: mock, baseUrl: 'https://prueba');

      await expectLater(
        api.get('/orders'),
        throwsA(isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 503)),
      );
    });

    test('sin conexión: una excepción de red lanza NetworkFailure', () async {
      final mock = MockClient((request) async {
        throw http.ClientException('sin red');
      });
      final api = ApiClient(client: mock, baseUrl: 'https://prueba');

      await expectLater(api.get('/orders'), throwsA(isA<NetworkFailure>()));
    });

    test('sin conexión: superar el timeout lanza NetworkFailure', () async {
      final mock = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return http.Response('{"status": "ok"}', 200);
      });
      final api = ApiClient(
          client: mock,
          baseUrl: 'https://prueba',
          timeout: const Duration(milliseconds: 50));

      await expectLater(api.get('/orders'), throwsA(isA<NetworkFailure>()));
    });

    test('300 no es éxito: lanza UnexpectedFailure con statusCode 300',
        () async {
      final mock = MockClient((request) async {
        return http.Response('', 300);
      });
      final api = ApiClient(client: mock, baseUrl: 'https://prueba');

      await expectLater(
        api.get('/orders'),
        throwsA(
            isA<UnexpectedFailure>().having((f) => f.statusCode, 'statusCode', 300)),
      );
    });
  });
}
