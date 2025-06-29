import 'package:flutter/material.dart';
import 'package:gestor_de_membresias/screens/menu_screen.dart';

void main() {
  print('Iniciando la aplicación...');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestor de Membresias',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color.fromARGB(97, 8, 138, 224)),
        ),
      ),
      home: MenuScreen(),
    );
  }
}