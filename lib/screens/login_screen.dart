import 'package:flutter/material.dart';
import '../services/login_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'register_screen.dart';
import 'recuperarContrase_a_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa usuario y contraseña')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final bool isAuthenticated = await LoginService.login(
        email: email,
        password: password,
      );

      if (isAuthenticated) {
        widget.onLoginSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrectos')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Membs\nGood',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2196F3),
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Bienvenido de nuevo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Inicia sesión para continuar',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Colors.blue,
                  ),
                  hintText: 'Usuario',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.blue,
                  ),
                  hintText: 'Contraseña',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RecuperarContrasenaScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Olvidé mi contraseña',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const SpinKitThreeBounce(
                      color: Color(0xFF2196F3),
                      size: 28,
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes cuenta?',
                    style: TextStyle(fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              // const SizedBox(height: 8),
              // const Text(
              //   'O ingresa con',
              //   style: TextStyle(fontSize: 15, color: Colors.black54),
              // ),
              // const SizedBox(height: 8),
              // SizedBox(
              //   width: double.infinity,
              //   height: 48,
              //   child: OutlinedButton(
              //     style: OutlinedButton.styleFrom(
              //       side: const BorderSide(color: Color(0xFF2196F3)),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(16),
              //       ),
              //     ),
              //     onPressed: _loginWithGoogle,
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Image.asset(
              //           'assets/google.png',
              //           height: 24,
              //           width: 24,
              //         ),
              //         const SizedBox(width: 12),
              //         const Text(
              //           'Iniciar con Google',
              //           style: TextStyle(
              //             color: Colors.black87,
              //             fontSize: 16,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}