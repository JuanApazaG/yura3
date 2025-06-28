import 'package:flutter/material.dart';
import 'package:gestor_de_membresias/models/usuario_membresia.dart';
import '../../services/usuario_membresia_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../calendario.dart'; // Importa tu calendario

class UsuariosMembresiasScreen extends StatefulWidget {
  const UsuariosMembresiasScreen({super.key});

  @override
  State<UsuariosMembresiasScreen> createState() =>
      _UsuariosMembresiasScreenState();
}

class _UsuariosMembresiasScreenState extends State<UsuariosMembresiasScreen> {
  final UsuarioMembresiaService _service = UsuarioMembresiaService();
  late Future<List<UsuarioMembresia>> _usuariosMembresias;

  @override
  void initState() {
    super.initState();
    _usuariosMembresias = _service.obtenerUsuariosMembresias();
  }

  String _formateaFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (_) {
      return fecha;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0, top: 8),
          child: Text(
            'Membresias',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<UsuarioMembresia>>(
        future: _usuariosMembresias,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SpinKitFadingCircle(color: Colors.blue));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay registros'));
          } else {
            final lista = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: lista.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final um = lista[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CalendarioScreen(
                          idUsuarioMembresia: um.idUsuarioMembresia,
                          fechaInicio: um.fechaInicio,
                          fechaFin: um.fechaFin,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B6CF6), Color(0xFF4F8CFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.13),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Opacity(
                            opacity: 0.15,
                            child: Icon(
                              Icons.circle,
                              size: 120,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      um.nombreMembresia,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      um.nombreUsuario,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Inicio ${_formateaFecha(um.fechaInicio)}",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.93),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "Fin ${_formateaFecha(um.fechaFin)}",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.93),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: um.estado == 'activa'
                                            ? Colors.green.withOpacity(0.8)
                                            : Colors.red.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        um.estado.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 6, right: 2),
                                decoration: BoxDecoration(
                                  color: um.estado == 'activa'
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFF76C6C),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(7),
                                child: Icon(
                                  um.estado == 'activa' ? Icons.check : Icons.close,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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