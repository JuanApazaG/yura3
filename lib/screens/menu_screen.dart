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
  bool microfonoActivo = false;

  void _abrirPerfil() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PerfilScreen(onLogout: widget.onLogout),
      ),
    );
  }

  void _abrirMicrofono() async {
    setState(() {
      microfonoActivo = true;
    });
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MicrofonoScreen(),
      ),
    );
    setState(() {
      microfonoActivo = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> paginas = [
      const ConsultasScreen(),
      const MicrofonoScreen(), // No se usa directamente, solo para el índice
      const PacientesScreen(),
    ];
    final List<String> titulos = [
      'Consultas',
      'Dictado',
      'Pacientes',
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/imagenes/logoJuli.png',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 12),
            Text(titulos[paginaActual]),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _abrirPerfil,
          ),
        ],
      ),
      body: paginas[paginaActual == 1 ? 0 : paginaActual], // Nunca mostrar MicrofonoScreen aquí
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: paginaActual,
        onTap: (int index) {
          if (microfonoActivo) {
            // Si el micrófono está activo, solo permitir el botón central
            if (index == 1) _abrirMicrofono();
            return;
          }
          if (index == 1) {
            _abrirMicrofono();
          } else {
            setState(() {
              paginaActual = index;
            });
          }
        },
        selectedItemColor: Colors.blue,
        selectedIconTheme: const IconThemeData(size: 34),
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.assignment,
              color: microfonoActivo ? Colors.grey : null,
            ),
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
          BottomNavigationBarItem(
            icon: Icon(
              Icons.supervised_user_circle,
              color: microfonoActivo ? Colors.grey : null,
            ),
            label: 'Pacientes',
          ),
        ],
      ),
    );
  }
}
