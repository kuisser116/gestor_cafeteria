import 'package:flutter/material.dart';
import 'package:gestor_cafeteria/producto.dart';
import 'package:gestor_cafeteria/repositorio_falso.dart';
import 'package:gestor_cafeteria/resultado.dart';

// IA: bloque generado con apoyo de OpenCode (Willy) para la nivelación T3.
// Pantalla con los tres estados controlados por la clase sellada Resultado.
class PantallaListaTresEstados extends StatefulWidget {
  const PantallaListaTresEstados({super.key});

  @override
  State<PantallaListaTresEstados> createState() =>
      _PantallaListaTresEstadosState();
}

class _PantallaListaTresEstadosState extends State<PantallaListaTresEstados> {
  final RepositorioFalso _repositorio = RepositorioFalso();
  Resultado<List<Producto>> _estado = const Cargando();

  Future<void> _cargar() async {
    setState(() => _estado = const Cargando());
    try {
      final productos = await _repositorio.obtener();
      // Después de un await la pantalla pudo haberse cerrado: si ya no está
      // montada, no hay nada que actualizar.
      if (!mounted) return;
      setState(() => _estado = Exito(productos));
    } catch (_) {
      if (!mounted) return;
      // Mensaje legible para la persona, sin excepción cruda ni stack trace.
      setState(() => _estado = const Error(
          'No se pudieron cargar los productos. Revisa tu conexión.'));
    }
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tienda del estacionamiento')),
      body: switch (_estado) {
        Cargando() => const Center(child: CircularProgressIndicator()),
        Exito(datos: final lista) => _ListaProductos(productos: lista),
        Error(mensaje: final mensaje) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(mensaje, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _cargar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
      },
    );
  }
}

// IA: bloque generado con apoyo de OpenCode (Willy): lista de tarjetas.
class _ListaProductos extends StatelessWidget {
  const _ListaProductos({required this.productos});

  final List<Producto> productos;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: productos.length,
      itemBuilder: (context, index) {
        final producto = productos[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(producto.nombre),
            subtitle: Text('\$${producto.precio.toStringAsFixed(2)}'),
            trailing: producto.enOferta
                ? const Chip(
                    label: Text('Oferta'),
                    backgroundColor: Colors.greenAccent,
                  )
                : null,
          ),
        );
      },
    );
  }
}
