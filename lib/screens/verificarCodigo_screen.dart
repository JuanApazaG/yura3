import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gestor_de_membresias/utils/Config.dart';
import 'ActualizarContrase_a_screen.dart';

class VerificarCodigoScreen extends StatefulWidget {
  final String email;
  const VerificarCodigoScreen({super.key, required this.email});

  @override
  State<VerificarCodigoScreen> createState() => _VerificarCodigoScreenState();
}

class _VerificarCodigoScreenState extends State<VerificarCodigoScreen> {
  final TextEditingController _codigoController = TextEditingController();
  bool _enviando = false;

  Future<void> _verificarCodigo() async {
    final pin = _codigoController.text.trim();
    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El código debe tener 6 dígitos')),
      );
      return;
    }

    setState(() {
      _enviando = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/api/verificar-pin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "email": widget.email,
          "pin": pin,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ActualizarContrasenaScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código incorrecto o expirado')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _enviando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificar código',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ingresa el código de 6 dígitos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enviado a: ${widget.email}',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _codigoController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
                  hintText: 'Código de 6 dígitos',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _enviando ? null : _verificarCodigo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _enviando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Verificar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}