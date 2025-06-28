import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:gestor_de_membresias/utils/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gestor_de_membresias/models/usuario.dart';

class UsuarioService {
  final String baseUrl = Config.baseUrl;

  Future<Usuario> obtenerUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/usuarios/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al obtener el usuario');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return Usuario.fromJson(data['data']);
  }

  Future<bool> actualizarNombre(String nuevoNombre) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/api/usuarios/nombre'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'nombre': nuevoNombre}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> actualizarEmail(String nuevoEmail) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/api/usuarios/email'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'email': nuevoEmail}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error al actualizar email: ${response.statusCode}');
      print('Respuesta: ${response.body}');
      return false;
    }
  }

  Future<bool> editarContrasena(
    String nuevaContrasena, {
    required String actualContrasena,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado');
    }

    final response = await http.patch(
      Uri.parse('$baseUrl/api/usuarios/password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'actual': actualContrasena, 'nueva': nuevaContrasena}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error al editar contraseña: ${response.statusCode}');
      print('Respuesta: ${response.body}');
      return false;
    }
  }

  Future<bool> actualizarImagen(File imagen) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Token no encontrado');
    }

    print('Ruta de la imagen: ${imagen.path}'); // <-- Depuración

    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('$baseUrl/api/usuarios/imagen'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', imagen.path));

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      print('Imagen actualizada correctamente: $respStr');
      return true;
    } else {
      print('Error al actualizar imagen: ${response.statusCode}');
      print('Respuesta backend: $respStr');
      return false;
    }
  }
}