// IA: bloque generado con apoyo de OpenCode (Willy) para la nivelación T3.
// Clase sellada que modela los tres estados de una pantalla.

sealed class Resultado<T> {
  const Resultado();
}

class Cargando<T> extends Resultado<T> {
  const Cargando();
}

class Exito<T> extends Resultado<T> {
  const Exito(this.datos);
  final T datos;
}

class Error<T> extends Resultado<T> {
  const Error(this.mensaje);
  final String mensaje;
}
