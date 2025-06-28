import 'package:flutter/material.dart';

class Paciente {
  final String nombre;
  final String especialidad;
  final String fechaIngreso;
  final String fotoUrl;

  Paciente({
    required this.nombre,
    required this.especialidad,
    required this.fechaIngreso,
    required this.fotoUrl,
  });
}

class PacientesScreen extends StatelessWidget {
  const PacientesScreen({Key? key}) : super(key: key);

  static final List<Paciente> pacientes = [
    Paciente(
      nombre: 'Juan Pérez',
      especialidad: 'Cardiología',
      fechaIngreso: '2023-01-15',
      fotoUrl: 'https://randomuser.me/api/portraits/men/1.jpg',
    ),
    Paciente(
      nombre: 'María López',
      especialidad: 'Pediatría',
      fechaIngreso: '2022-12-10',
      fotoUrl: 'https://randomuser.me/api/portraits/women/2.jpg',
    ),
    Paciente(
      nombre: 'Carlos Sánchez',
      especialidad: 'Dermatología',
      fechaIngreso: '2023-02-20',
      fotoUrl: 'https://randomuser.me/api/portraits/men/3.jpg',
    ),
    Paciente(
      nombre: 'Ana Torres',
      especialidad: 'Neurología',
      fechaIngreso: '2023-03-05',
      fotoUrl: 'https://randomuser.me/api/portraits/women/4.jpg',
    ),
    Paciente(
      nombre: 'Luis Gómez',
      especialidad: 'Ginecología',
      fechaIngreso: '2023-01-30',
      fotoUrl: 'https://randomuser.me/api/portraits/men/5.jpg',
    ),
    Paciente(
      nombre: 'Sofía Ramírez',
      especialidad: 'Oftalmología',
      fechaIngreso: '2022-11-25',
      fotoUrl: 'https://randomuser.me/api/portraits/women/6.jpg',
    ),
    Paciente(
      nombre: 'Miguel Castro',
      especialidad: 'Traumatología',
      fechaIngreso: '2023-02-12',
      fotoUrl: 'https://randomuser.me/api/portraits/men/7.jpg',
    ),
    Paciente(
      nombre: 'Lucía Herrera',
      especialidad: 'Psiquiatría',
      fechaIngreso: '2023-03-01',
      fotoUrl: 'https://randomuser.me/api/portraits/women/8.jpg',
    ),
    Paciente(
      nombre: 'Andrés Ruiz',
      especialidad: 'Urología',
      fechaIngreso: '2023-01-18',
      fotoUrl: 'https://randomuser.me/api/portraits/men/9.jpg',
    ),
    Paciente(
      nombre: 'Valentina Díaz',
      especialidad: 'Endocrinología',
      fechaIngreso: '2022-12-28',
      fotoUrl: 'https://randomuser.me/api/portraits/women/10.jpg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pacientes.length,
      itemBuilder: (context, index) {
        final paciente = pacientes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 3,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(paciente.fotoUrl),
              radius: 28,
            ),
            title: Text(paciente.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Especialidad: ${paciente.especialidad}'),
                Text('Fecha de ingreso: ${paciente.fechaIngreso}'),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
} 