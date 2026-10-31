// IA: bloque generado con apoyo de OpenCode (Willy) para la nivelación T3.
// Entidad del proyecto (ParkingApp · tienda): un producto con precio y oferta.

class Producto {
  const Producto({
    required this.nombre,
    required this.precio,
    this.enOferta = false,
  });

  final String nombre;
  final double precio;
  // Campo opcional con valor por defecto: la mayoría de los productos no están
  // en oferta; `false` por defecto evita un bool? y null-checks.
  final bool enOferta;
}
