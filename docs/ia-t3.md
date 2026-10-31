# Declaración de IA — Nivelación T3 (lista con tres estados)

**Herramienta:** OpenCode (Willy), asistente de IA — política **Nivel 2: IA como herramienta declarada**.

**Prompts principales:**

1. Generar la clase sellada `Resultado<T>` (Cargando, Exito, Error) para la pantalla y explicarme por qué el `switch` sobre un `sealed` no necesita `default`.
2. Generar la entidad `Producto` con campos `final`, constructor `const` con named parameters y un campo opcional, y el repositorio falso que falla la primera llamada.
3. Generar la pantalla `StatefulWidget` con los tres estados, el ciclo `setState` y el manejo de `mounted` después del `await`.
4. Preguntas de comprensión: ¿para qué sirve `if (!mounted) return;` después del `await`?, ¿por qué `ListView.builder` y no `ListView`?, ¿qué pasa si agrego un estado nuevo a la sealed class?

**Qué acepté:** la estructura de los tres estados, el `switch` exhaustivo sin `default`, el guardián `mounted` antes de cada `setState` posterior a un `await`, y el manejo de errores con mensaje legible en español (sin excepción cruda).

**Qué cambié o rechacé:**

- Cambié el patrón `Exito(productos: …)` por `Exito(datos: …)`: el campo de mi clase se llama `datos` y el patrón debe coincidir con el nombre real del campo (lo comprobé al compilar).
- Rechacé usar el texto crudo de la excepción en la UI: la tarea pide un mensaje legible, así que la pantalla muestra un mensaje propio y el `throw` real solo queda en el repositorio.
- Ajusté la entidad del ejemplo (`Tarea`) por `Producto`, que es la entidad de mi proyecto (ParkingApp), y puse 6 elementos de ejemplo.
- Agregué el ícono y el espaciado del estado de error a mi gusto para que se vea bien en el teléfono.

**Cómo lo probé:**

- `flutter analyze` → sin errores ni advertencias.
- `flutter test` → las 21 pruebas siguen en verde.
- Corrí la app en el navegador y probé los tres estados a mano: la primera carga muestra `Cargando...` y luego el error con `Reintentar`; al tocar `Reintentar` vuelve a `Cargando...` y termina en la lista de 6 productos. Las tres capturas están en la evidencia.
- Revisé cada bloque marcado con `// IA:` antes de entregar: cada línea me la puedo explicar (clase sellada, patrones del switch, `setState`, `mounted`, `ListView.builder`).

**Defensa oral:** mi repaso está en los comentarios del propio código y en esta bitácora; me siento capaz de explicar cualquier bloque y de modificarlo en vivo.
