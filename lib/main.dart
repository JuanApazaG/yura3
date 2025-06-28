import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:gestor_de_membresias/screens/login_screen.dart';
import 'package:gestor_de_membresias/screens/menu_screen.dart'; 
void main() { 
  print('Iniciando la aplicación...'); // Mensaje de inicio
  runApp(const MyApp());
} 

class MyApp extends StatefulWidget { 
  const MyApp({super.key}); 

  @override
  MyAppState createState() => MyAppState(); 
}

class MyAppState extends State<MyApp> { 
  bool _isAuthenticated = false; 
  bool _isLoading = true; 

  @override
  void initState() { 
    super.initState();
    _checkLoginStatus(); 
  }

  Future<void> _checkLoginStatus() async { // Verifica el estado de autenticación guardado
    final prefs = await SharedPreferences.getInstance(); // Obtiene las preferencias guardadas
    setState(() {
      _isAuthenticated = prefs.getBool('isAuthenticated') ?? false; // Lee si está autenticado
      _isLoading = false; // Termina la carga
    });
  }

  Future<void> _onLoginSuccess() async { // Se llama cuando el login es exitoso
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true); // Guarda que el usuario está autenticado
    setState(() {
      _isAuthenticated = true; // Actualiza el estado
    });
  }

  Future<void> _logout() async { // Se llama para cerrar sesión
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated'); // Elimina el estado de autenticación guardado
    await prefs.remove('token'); // Elimina el token guardado
    setState(() {
      _isAuthenticated = false; // Actualiza el estado
    });
  }

  @override
  Widget build(BuildContext context) { // Construye la interfaz de usuario
    if (_isLoading) { // Si está cargando, muestra un spinner
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: SpinKitFadingCircle(
            color: Colors.lightBlue,
            size: 50.0,
          )),
        ),
      );
    }
    return MaterialApp( // Si ya cargó, muestra la app normal
      debugShowCheckedModeBanner: false, // Quita la etiqueta de debug
      title: 'Gestor de Membresias', // Título de la app
      theme: ThemeData(
        primarySwatch: Colors.lightBlue, // Color principal
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color.fromARGB(97, 8, 138, 224)), // Estilo de texto
        ),
      ),
      home: _isAuthenticated // Decide qué pantalla mostrar
          ? MenuScreen(onLogout: _logout) // Si está autenticado, muestra el menú
          : LoginScreen(onLoginSuccess: _onLoginSuccess), // Si no, muestra login
    );
  }
}