import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestor_de_membresias/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static const String baseUrl = Config.baseUrl; // URL base desde config.dart

  static Future<bool> login({
    required String email,
    required String password,
  })
  async {
    final Uri url = Uri.parse('$baseUrl/api/login'); // Endpoint del backend

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email, // Campo esperado por el backend
          'contrase_a': password, // Cambiado de 'password' a 'contrase_a'
        }),
      );

      //print('Statusaaaaaaaaaaaaaaaaaaaaaaaaaaa: ${response.statusCode}');
      //print('BodyAAAAAAAAAAAAAAAAAAAAAAAAAAAA: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Verifica si el backend indica éxito
        if (responseData['success'] == true) {
          // Puedes guardar el token si es necesario
          final String token = responseData['data']['token'];
          print('Token recibido: $token');

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'token',
            token,
          ); // Guarda el token en SharedPreferences

          // Aquí puedes guardar el token en SharedPreferences si lo necesitas
          return true; // Inicio de sesión exitoso
        } else {
          return false; // Credenciales incorrectas
        }
      } else {
        return false; // Error en la solicitud
      }
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }
}
