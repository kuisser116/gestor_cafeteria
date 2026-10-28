# gestor_cafeteria

Cliente Flutter de una cafetería: consulta y gestiona pedidos contra una API pequeña en Node.js + SQLite (`mini_backend`). La app distingue los fallos de red/servidor con una jerarquía de `Failure` tipada.

## Requisitos

- Flutter (Dart SDK 3.13.2)
- Node.js 22.13 o superior (para el backend)

## Backend: mini_backend

- Repositorio: https://github.com/DMI-2026/mini_backend
- Versión probada: commit `94d2533` de la rama master (27 de octubre de 2026)
- Este repositorio **no incluye** el backend; solo se referencia aquí.

```bash
git clone https://github.com/DMI-2026/mini_backend.git
cd mini_backend
node server.js          # no requiere npm install
# verificar: curl http://localhost:8000/health  ->  {"status":"ok"}
```

## Ejecutar la app

```bash
flutter pub get

# Emulador de Android (usa 10.0.2.2 automáticamente):
flutter run

# Chrome:
flutter run -d chrome

# Celular en la misma red (indica la IP de tu computadora):
flutter run --dart-define=API_URL=http://<IP-de-tu-computadora>:8000
```

Fuera de desarrollo local el cliente exige `https`.

## Pruebas

```bash
flutter test        # failure_test.dart + http_client_test.dart (MockClient, sin red)
flutter analyze     # sin errores ni advertencias
```

## Estructura

```
lib/core/   http_client.dart (ApiClient), failure.dart (jerarquía de fallos),
            token_storage.dart, failure.dart
lib/        main.dart
test/core/  failure_test.dart, http_client_test.dart
android/    platforma Android    web/  platforma web
```
