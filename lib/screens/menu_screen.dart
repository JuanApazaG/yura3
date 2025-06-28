import 'package:flutter/material.dart';
import 'package:gestor_de_membresias/screens/items_menu/consultas_screen.dart';
import 'package:gestor_de_membresias/screens/items_menu/microfono_screen.dart';
import 'package:gestor_de_membresias/screens/items_menu/pacientes_screen.dart';
import 'package:gestor_de_membresias/screens/items_menu/perfil_screen.dart';

class MenuScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const MenuScreen({super.key, required this.onLogout});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int paginaActual = 0;

  void _abrirPerfil() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PerfilScreen(onLogout: widget.onLogout),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> paginas = [
      const ConsultasScreen(),
      const MicrofonoScreen(),
      const PacientesScreen(),
    ];
    final List<String> titulos = [
      'Consultas',
      'Dictado',
      'Pacientes',
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(titulos[paginaActual]),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _abrirPerfil,
          ),
        ],
      ),
      body: paginas[paginaActual],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaActual,
        onTap: (int index) {
          setState(() {
            paginaActual = index;
          });
        },
        selectedItemColor: Colors.blue,
        selectedIconTheme: const IconThemeData(size: 34),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Consultas',
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.mic, color: Colors.white, size: 34),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Pacientes',
          ),
        ],
      ),
    );
  }
}
