import 'package:flutter_secure_storage/flutter_secure_storage.dart';
 
/// Contrato para guardar el token de sesión. La app depende de esta
/// abstracción, no del plugin, para poder probarla sin el sistema operativo.
abstract class TokenStorage {
  Future<String?> read();
  Future<void> save(String token);
  Future<void> clear();
}
 
/// Guarda el token en Keychain (iOS) o Keystore (Android).
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();
 
  static const _key = 'auth_token';
  final FlutterSecureStorage _storage;
  
  @override
  Future<String?> read() => _storage.read(key: _key);
 
  @override
  Future<void> save(String token) => _storage.write(key: _key, value: token);
 
  @override
  Future<void> clear() => _storage.delete(key: _key);
}
 
/// Solo para pruebas: vive en memoria y se pierde al cerrar el proceso.
class InMemoryTokenStorage implements TokenStorage {
  InMemoryTokenStorage([this._token]);
 
  String? _token;
 
  @override
  Future<String?> read() async => _token;
 
  @override
  Future<void> save(String token) async => _token = token;
 
  @override
  Future<void> clear() async => _token = null;
}
