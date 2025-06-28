import 'package:flutter/material.dart';
import 'package:gestor_de_membresias/services/usuario_service.dart';
import 'package:gestor_de_membresias/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gestor_de_membresias/utils/Config.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<List<Map<String, dynamic>>> obtenerMembresiasMasConcurridas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/membresias-mas-concurridas'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener membresías');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerMembresiasMasAsistencias() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/membresias-mas-asistencias'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Error al obtener membresías por asistencias');
    }
  }

  Future<Usuario> obtenerUsuario() async {
    return await UsuarioService().obtenerUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inicio',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<Usuario>(
        future: obtenerUsuario(),
        builder: (context, usuarioSnapshot) {
          if (usuarioSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (usuarioSnapshot.hasError) {
            return Center(child: Text('Error: ${usuarioSnapshot.error}'));
          }
          final usuario = usuarioSnapshot.data!;
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: obtenerMembresiasMasConcurridas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              final membresias = snapshot.data!;
              return FutureBuilder<List<Map<String, dynamic>>>(
                future: obtenerMembresiasMasAsistencias(),
                builder: (context, asistenciasSnapshot) {
                  if (asistenciasSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (asistenciasSnapshot.hasError) {
                    return Center(child: Text('Error: ${asistenciasSnapshot.error}'));
                  }
                  final asistencias = asistenciasSnapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            usuario.imagen != null && usuario.imagen.isNotEmpty
                                ? CircleAvatar(
                                    radius: 32,
                                    backgroundImage: NetworkImage(usuario.imagen),
                                    backgroundColor: const Color(0xFF3B6CF6),
                                  )
                                : Container(
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF3B6CF6),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                            const SizedBox(width: 16),
                            Text(
                              'Bienvenido, ${usuario.nombre}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Membresías más concurridas',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        membresias.isEmpty
                            ? const Text('No hay datos para mostrar')
                            : SizedBox(
                                height: 220,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround,
                                    maxY: (membresias.map((e) => (e['cantidad'] as int)).reduce((a, b) => a > b ? a : b) + 1).toDouble(),
                                    barTouchData: BarTouchData(enabled: true),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 1,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            if (value % 1 != 0) return const SizedBox();
                                            return Text(
                                              value.toInt().toString(),
                                              style: const TextStyle(fontSize: 12),
                                            );
                                          },
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (double value, TitleMeta meta) {
                                            final idx = value.toInt();
                                            if (idx < 0 || idx >= membresias.length) return const SizedBox();
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                membresias[idx]['nombre'],
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    barGroups: [
                                      for (int i = 0; i < membresias.length; i++)
                                        BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: (membresias[i]['cantidad'] as int).toDouble(),
                                              color: Colors.blueAccent,
                                              width: 24,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                        const SizedBox(height: 32),
                        const Text(
                          '-----',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: asistencias.isEmpty
                              ? const Text('---')
                              : ListView.separated(
                                  itemCount: asistencias.length,
                                  separatorBuilder: (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final item = asistencias[index];
                                    return ListTile(
                                      leading: const Icon(Icons.star, color: Colors.orange),
                                      title: Text(item['nombre']),
                                      trailing: Text(
                                        item['cantidad'].toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}