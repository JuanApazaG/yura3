import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestor_de_membresias/services/usuario_service.dart';
import 'package:gestor_de_membresias/models/usuario.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';

class PerfilScreen extends StatelessWidget {
  final VoidCallback onLogout;
  const PerfilScreen({super.key, required this.onLogout});

  void _mostrarFormularioEdicion(
    BuildContext context,
    Usuario usuario,
    VoidCallback onUpdated,
  ) {
    final nombreController = TextEditingController(text: usuario.nombre);
    final actualContrasenaController = TextEditingController();
    final nuevaContrasenaController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Editar Perfil',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final nuevoNombre = nombreController.text.trim();
                      if (nuevoNombre.isNotEmpty &&
                          nuevoNombre != usuario.nombre) {
                        final exito = await UsuarioService().actualizarNombre(
                          nuevoNombre,
                        );
                        if (exito) {
                          Navigator.pop(context);
                          onUpdated();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Nombre actualizado')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al actualizar nombre'),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B6CF6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Actualizar Nombre',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: actualContrasenaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña Actual',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nuevaContrasenaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nueva Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final actual = actualContrasenaController.text.trim();
                      final nueva = nuevaContrasenaController.text.trim();
                      if (actual.isNotEmpty && nueva.isNotEmpty) {
                        final exito = await UsuarioService().editarContrasena(
                          nueva,
                          actualContrasena: actual,
                        );
                        if (exito) {
                          Navigator.pop(context);
                          onUpdated();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Contraseña actualizada')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Error al actualizar contraseña'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Completa ambos campos de contraseña'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Actualizar Contraseña',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _seleccionarImagen(BuildContext context, VoidCallback onUpdated) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final exito = await UsuarioService().actualizarImagen(File(pickedFile.path));
      if (exito) {
        onUpdated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen actualizada')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar imagen')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0, top: 8),
          child: Text(
            'Perfilr',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: onLogout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: FutureBuilder<Usuario>(
        future: UsuarioService().obtenerUsuario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SpinKitFadingCircle(color: Colors.blue));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final usuario = snapshot.data!;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    usuario.imagen != null && usuario.imagen.isNotEmpty
                        ? CircleAvatar(
                            radius: 48,
                            backgroundImage: NetworkImage(usuario.imagen),
                            backgroundColor: const Color(0xFF3B6CF6),
                          )
                        : Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF3B6CF6),
                            ),
                            padding: const EdgeInsets.all(28),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          _seleccionarImagen(context, () {
                            (context as Element).reassemble();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(
                            Icons.edit,
                            size: 22,
                            color: Color(0xFF3B6CF6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  usuario.nombre,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  usuario.email,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 180,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      _mostrarFormularioEdicion(context, usuario, () {
                        (context as Element).reassemble();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B6CF6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Editar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}