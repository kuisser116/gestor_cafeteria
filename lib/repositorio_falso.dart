import 'package:gestor_cafeteria/producto.dart';

// IA: bloque generado con apoyo de OpenCode (Willy) para la nivelación T3.
// Repositorio falso: la primera llamada falla (para probar el estado de error
// y el botón Reintentar) y a partir de la segunda devuelve los productos.
class RepositorioFalso {
  int _llamadas = 0;

  Future<List<Producto>> obtener() async {
    await Future.delayed(const Duration(seconds: 1));
    _llamadas++;
    if (_llamadas == 1) throw Exception('Sin conexión');
    return const [
      Producto(nombre: 'Agua 600 ml', precio: 15.0),
      Producto(nombre: 'Café americano', precio: 42.0, enOferta: true),
      Producto(nombre: 'Galleta', precio: 12.0),
      Producto(nombre: 'Refresco 355 ml', precio: 25.0),
      Producto(nombre: 'Papas sazonadas', precio: 20.0, enOferta: true),
      Producto(nombre: 'Croissant', precio: 28.0),
    ];
  }
}
