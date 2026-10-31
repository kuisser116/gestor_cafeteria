import 'package:flutter/material.dart';
import 'package:gestor_cafeteria/pantalla_lista.dart';

// IA: main ajustado con apoyo de OpenCode (Willy): ahora abre la pantalla de
// la nivelación T3 (tres estados).
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
      ),
      home: const PantallaListaTresEstados(),
    );
  }
}
