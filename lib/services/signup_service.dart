import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestor_de_membresias/utils/config.dart';

class SignupService {
  static const String baseUrl = Config.baseUrl;

  static Future<bool> signup({
    required String nombre,
    required String email,
    required String password,
    required int idRol,
    required String imagen,
    // Puedes quitar googleId y proveedor si el backend no los usa
  }) async {
    final Uri url = Uri.parse('$baseUrl/api/singup');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombre,
        'email': email,
        'contrase_a': password, // igual que en Postman y backend
        'id_rol': idRol,        // minúscula y guion bajo
        'imagen': imagen,
      }),
    );

    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return true;
      } else {
        throw Exception(data['error'] ?? 'Error desconocido en el registro');
      }
    } else {
      final data = json.decode(response.body);
      throw Exception(data['error'] ?? 'Error HTTP: ${response.statusCode}');
    }
  }
}