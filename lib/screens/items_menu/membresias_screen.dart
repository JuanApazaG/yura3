import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/membresia.dart';
import '../../services/membresia_service.dart';

class MembresiasScreen extends StatefulWidget {
  const MembresiasScreen({super.key});

  @override
  State<MembresiasScreen> createState() => _MembresiasScreenState();
}

class _MembresiasScreenState extends State<MembresiasScreen> {
  final MembresiaService _membresiaService = MembresiaService();
  late Future<List<Membresia>> _membresias;

  @override
  void initState() {
    super.initState();
    _cargarMembresias();
  }

  void _cargarMembresias() {
    setState(() {
      _membresias = _membresiaService.obtenerMembresias();
    });
  }

  Future<void> _anadirOModificarMembresia({Membresia? membresia}) async {
    final TextEditingController nombreController = TextEditingController(
      text: membresia?.nombre ?? '',
    );
    final TextEditingController descripcionController = TextEditingController(
      text: membresia?.descripcion ?? '',
    );
    final TextEditingController duracionController = TextEditingController(
      text: membresia?.duracionDias.toString() ?? '',
    );
    final TextEditingController costoController = TextEditingController(
      text: membresia?.costoTotal.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            membresia == null ? 'Añadir Membresía' : 'Editar Membresía',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: descripcionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: duracionController,
                  decoration: const InputDecoration(
                    labelText: 'Duración (días)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: costoController,
                  decoration: const InputDecoration(labelText: 'Costo Total'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nombreController.text.isEmpty ||
                    descripcionController.text.isEmpty ||
                    duracionController.text.isEmpty ||
                    costoController.text.isEmpty) {
                  // Validación simple para asegurarte de que los campos no estén vacíos
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor, completa todos los campos'),
                    ),
                  );
                  return;
                }

                if (membresia == null) {
                  // Añadir nueva membresía
                  await _membresiaService.anadirMembresia(
                    nombre: nombreController.text,
                    descripcion: descripcionController.text,
                    duracionDias: int.parse(duracionController.text),
                    costoTotal: int.parse(costoController.text),
                  );
                } else {
                  // Editar membresía existente
                  await _membresiaService.editarMembresia(
                    id: membresia.idMembresia,
                    nombre: nombreController.text,
                    descripcion: descripcionController.text,
                    duracionDias: int.parse(duracionController.text),
                    costoTotal: int.parse(costoController.text),
                  );
                }

                Navigator.of(context).pop(); // Cierra el diálogo
                _cargarMembresias(); // Recarga la lista de membresías
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarMembresia(int id) async {
    await _membresiaService.eliminarMembresia(id);
    _cargarMembresias(); // Recargar la lista
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Membresías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _anadirOModificarMembresia(),
          ),
        ],
      ),
      body: FutureBuilder<List<Membresia>>(
        future: _membresias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SpinKitFadingCircle(color: Colors.blue));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay membresías disponibles'));
          } else {
            final membresias = snapshot.data!;
            return ListView.builder(
              itemCount: membresias.length,
              itemBuilder: (context, index) {
                final membresia = membresias[index];
                return ListTile(
                  title: Text(membresia.nombre),
                  subtitle: Text(membresia.descripcion),
                  leading: CircleAvatar(
                    child: Text(membresia.idMembresia.toString()),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed:
                            () => _anadirOModificarMembresia(
                              membresia: membresia,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.blue),
                        onPressed:
                            () => _eliminarMembresia(membresia.idMembresia),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
