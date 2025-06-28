import 'package:flutter/material.dart';
import 'package:gestor_de_membresias/screens/items_menu/home_screen.dart';
//import 'package:gestor_de_membresias/screens/items_menu/membresias_screen.dart';
import 'package:gestor_de_membresias/screens/items_menu/perfil_screen.dart';
import 'package:gestor_de_membresias/screens/items_menu/usuarios_membresias_screen.dart';

class MenuScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const MenuScreen({super.key, required this.onLogout});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  int paginaActual = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> paginas = [
      const HomeScreen(),
      const UsuariosMembresiasScreen(),
      //const MembresiasScreen(),
      PerfilScreen(
        onLogout: widget.onLogout,
      ), // <-- Aquí pasas el callback correctamente
    ];
    return Scaffold(
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.supervised_user_circle),
            label: 'Mis Membresías',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
