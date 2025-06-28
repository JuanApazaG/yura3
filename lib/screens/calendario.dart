import 'package:flutter/material.dart';
import 'package:gestor_de_membresias/utils/Config.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CalendarioScreen extends StatefulWidget {
  final int idUsuarioMembresia;
  final String fechaInicio;
  final String fechaFin;

  const CalendarioScreen({
    super.key,
    required this.idUsuarioMembresia,
    required this.fechaInicio,
    required this.fechaFin,
  });

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  Map<DateTime, int> asistencias = {};
  List<Map<String, dynamic>> pagos = [];
  double deuda = 0.0;
  double totalPagado = 0.0;
  String nombreMembresia = '';
  final String baseUrl = Config.baseUrl;

  @override
  void initState() {
    super.initState();
    fetchAsistencias();
    fetchPagos();
    fetchDeudaYTotalPagado();
  }

  Future<void> fetchAsistencias() async {
    final url = Uri.parse(
      '$baseUrl/api/asistencias/usuario_membresia/${widget.idUsuarioMembresia}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      Map<DateTime, int> temp = {};
      for (var item in data['data']) {
        final date = DateTime.parse(item['fecha']);
        temp[DateTime(date.year, date.month, date.day)] = item['id_estado'];
      }
      setState(() {
        asistencias = temp;
      });
    }
  }

  Future<void> fetchPagos() async {
    final url = Uri.parse('$baseUrl/api/pagos_usuario_membresia');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"id_usuario_membresia": widget.idUsuarioMembresia}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        pagos = List<Map<String, dynamic>>.from(data['data']);
      });
    }
  }

  Future<void> fetchDeudaYTotalPagado() async {
    final url = Uri.parse('$baseUrl/api/deuda_usuario_membresia');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({"id_usuario_membresia": widget.idUsuarioMembresia}),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Buscar la membresía correspondiente
      final membresia = data.firstWhere(
        (m) => m['id_membresia'] == widget.idUsuarioMembresia,
        orElse: () => null,
      );
      setState(() {
        if (membresia != null) {
          deuda =
              (membresia['deuda'] is int)
                  ? (membresia['deuda'] as int).toDouble()
                  : (membresia['deuda'] is double)
                  ? membresia['deuda']
                  : double.tryParse(membresia['deuda'].toString()) ?? 0.0;
          totalPagado =
              (membresia['total_pagado'] is int)
                  ? (membresia['total_pagado'] as int).toDouble()
                  : (membresia['total_pagado'] is double)
                  ? membresia['total_pagado']
                  : double.tryParse(membresia['total_pagado'].toString()) ??
                      0.0;
          nombreMembresia = membresia['nombre_membresia'] ?? '';
        } else {
          deuda = 0.0;
          totalPagado = 0.0;
          nombreMembresia = '';
        }
      });
    }
  }

  Future<void> solicitarPermiso(DateTime fecha) async {
    final url = Uri.parse('$baseUrl/api/asistencias/solicitar_permiso');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "fecha": fecha.toUtc().toIso8601String(),
        "id_usuario_membresia": widget.idUsuarioMembresia,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        setState(() {
          asistencias[DateTime(fecha.year, fecha.month, fecha.day)] = 3;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso registrado correctamente')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Error al registrar permiso'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar permiso')),
      );
    }
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    final estado =
        asistencias[DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
        )];
    final isInRange =
        !selectedDay.isBefore(DateTime.parse(widget.fechaInicio)) &&
        !selectedDay.isAfter(DateTime.parse(widget.fechaFin));
    if (estado == null && isInRange) {
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Permiso',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '¿Deseas solicitar permiso para el ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}?',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF2196F3),
                            ),
                            label: const Text(
                              'Cancelar',
                              style: TextStyle(color: Color(0xFF2196F3)),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2196F3)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text(
                              'Si',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      );
      if (confirm == true) {
        await solicitarPermiso(selectedDay);
      }
    }
  }

  Color? getMarkerColor(int? estado) {
    switch (estado) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.red;
      case 3:
        return Colors.yellow[700];
      default:
        return null;
    }
  }

  double get totalPagos {
    double total = 0;
    for (var pago in pagos) {
      final monto = double.tryParse(pago['monto_pagado'] ?? '0') ?? 0;
      total += monto;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime firstDay = DateTime.parse(widget.fechaInicio);
    final DateTime lastDay = DateTime.parse(widget.fechaFin);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Duración de Membresía',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: firstDay,
              calendarFormat: CalendarFormat.month,
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final estado =
                      asistencias[DateTime(day.year, day.month, day.day)];
                  final color = getMarkerColor(estado);
                  if (color != null) {
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return null;
                },
                todayBuilder: (context, day, focusedDay) {
                  final estado =
                      asistencias[DateTime(day.year, day.month, day.day)];
                  final color = getMarkerColor(estado) ?? Colors.blue;
                  return Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
              onDaySelected: onDaySelected,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Vigencia: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.fechaInicio))} a ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.fechaFin))}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            if (nombreMembresia.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Membresía: $nombreMembresia',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Pagos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Total pagado: \$${totalPagado.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Deuda: \$${deuda.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            pagos.isEmpty
                ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Aún no se registraron pagos',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
                : Table(
                  border: TableBorder.all(color: Color(0xFF2196F3)),
                  columnWidths: const {
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(),
                    2: FlexColumnWidth(),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(color: Color(0xFF2196F3)),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Fecha',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Monto',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Estado',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...pagos.map(
                      (pago) => TableRow(
                        decoration: const BoxDecoration(color: Colors.white),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              pago['fecha_pago'] != null
                                  ? DateFormat('dd/MM/yyyy').format(
                                    DateTime.parse(
                                      pago['fecha_pago'],
                                    ).toLocal(),
                                  )
                                  : '',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              pago['monto_pagado'] ?? '',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Pagado',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          ],
        ),
      ),
    );
  }
}
