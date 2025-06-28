import 'package:flutter/material.dart';
import 'package:gestor_de_membresias/services/signup_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final exito = await SignupService.signup(
        nombre: _nombreController.text,
        email: _emailController.text,
        password: _passwordController.text,
        idRol: 1, // Rol fijo
        imagen: "", // Imagen vacía
      );

      setState(() => _isLoading = false);

      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Registro exitoso!')),
        );
        Navigator.pop(context); // Vuelve al login
      }
    } catch (e) {
      setState(() => _isLoading = false);
      // Si el error contiene 201, mostrar éxito y volver al login
      if (e.toString().contains('201')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Registro exitoso!')),
        );
        Navigator.pop(context); // Vuelve al login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar: $e')),
        );
      }
    }
  }

  Future<void> _registerWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bienvenido, ${account.displayName ?? account.email}')),
        );
        Navigator.pop(context); // O navega a la pantalla principal
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registro cancelado')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar con Google: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Membs\nGood",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "¡Bienvenido!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Crea una cuenta para comenzar",
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF1976D2)),
                    hintText: 'Nombre de usuario',
                    filled: true,
                    fillColor: const Color(0xFFF7FAFD),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Ingrese su nombre' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF1976D2)),
                    hintText: 'Email',
                    filled: true,
                    fillColor: const Color(0xFFF7FAFD),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Ingrese su email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF1976D2)),
                    hintText: 'Contraseña',
                    filled: true,
                    fillColor: const Color(0xFFF7FAFD),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? 'Ingrese su contraseña' : null,
                ),
                const SizedBox(height: 28),
                _isLoading
                    ? const CircularProgressIndicator()
                    : SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _registrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Registrarme',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Letra blanca
                            ),
                          ),
                        ),
                      ),
                const SizedBox(height: 18),
                // SizedBox(
                //   width: double.infinity,
                //   height: 54,
                //   child: ElevatedButton.icon(
                //     icon: Image.asset(
                //       'assets/google.png',
                //       height: 28,
                //       width: 28,
                //     ),
                //     label: const Text(
                //       'Registrarse con Google',
                //       style: TextStyle(
                //         color: Colors.black87,
                //         fontWeight: FontWeight.w600,
                //         fontSize: 16,
                //       ),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.white,
                //       foregroundColor: Colors.black87,
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(16),
                //         side: const BorderSide(color: Colors.black12),
                //       ),
                //       elevation: 0,
                //     ),
                //     onPressed: _isLoading ? null : _registerWithGoogle,
                //   ),
                // ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}