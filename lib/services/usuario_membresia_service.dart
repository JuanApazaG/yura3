import 'dart:convert';

import 'package:gestor_de_membresias/models/usuario_membresia.dart';
import 'package:gestor_de_membresias/utils/config.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioMembresiaService {
  final String baseUrl = Config.baseUrl;

  Future<List<UsuarioMembresia>> obtenerUsuariosMembresias() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado, inicia sesión primero');
    }

    final response = await get(
      Uri.parse('$baseUrl/api/usuarios_membresias_mobile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200){
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (!jsonResponse.containsKey('data')) {
        throw Exception('La respuesta del backend no contiene la clave "data"');
      }

      final List<dynamic> data = jsonResponse['data'];
      return data.map((json) => UsuarioMembresia.fromJson(json)).toList();
    } else {
      throw Exception(
        'Error al cargar las membresías de los usuarios: ${response.statusCode} - ${response.reasonPhrase}'
      );
    }
  }
}