import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:gestor_de_membresias/models/membresia.dart';
import 'package:gestor_de_membresias/utils/config.dart';

class MembresiaService {
  final String baseUrl = Config.baseUrl;

  Future<List<Membresia>> obtenerMembresias() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/membresias'));

      if (response.statusCode == 200) {
        // Decodifica la respuesta como un objeto JSON
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Verifica si la clave "data" existe
        if (!jsonResponse.containsKey('data')) {
          throw Exception('La respuesta del backend no contiene la clave "data"');
        }

        // Accede a la clave "data" que contiene la lista de membresías
        final List<dynamic> data = jsonResponse['data'];

//data.map(...):
//Recorre cada elemento de la lista data.
//Por cada elemento, aplica la función (json) => Membresia.fromJson(json).
//Membresia.fromJson(json):
//Convierte cada elemento de la lista (que es un mapa) en un objeto Membresia.

        // Convierte cada elemento de la lista en un objeto Membresia
        return data.map((json) => Membresia.fromJson(json)).toList();
      } else {
        throw Exception('Error al cargar las membresías: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al cargar las membresías desde el backend: $e');
    }
  }

  Future<void> anadirMembresia({
  required String nombre,
  required String descripcion,
  required int duracionDias,
  required int costoTotal,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/membresias'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'nombre': nombre,
      'descripcion': descripcion,
      'duracion_dias': duracionDias,
      'costo_total': costoTotal,
    }),
  );

  if (response.statusCode != 201) {
    throw Exception('Error al añadir la membresía');
  }
}

Future<void> editarMembresia({
  required int id,
  required String nombre,
  required String descripcion,
  required int duracionDias,
  required int costoTotal,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/api/membresias/$id'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'nombre': nombre,
      'descripcion': descripcion,
      'duracion_dias': duracionDias,
      'costo_total': costoTotal,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al editar la membresía');
  }
}

Future<void> eliminarMembresia(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/api/membresias/$id'),
  );

  if (response.statusCode != 200) {
    throw Exception('Error al eliminar la membresía');
  }
}
}

