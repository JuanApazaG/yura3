import 'package:flutter/material.dart';

class Consulta {
  final String nombrePaciente;
  final String numeroConsulta;
  final String resumen;
  final String pdfPreviewUrl;

  Consulta({
    required this.nombrePaciente,
    required this.numeroConsulta,
    required this.resumen,
    required this.pdfPreviewUrl,
  });
}

class ConsultasScreen extends StatelessWidget {
  const ConsultasScreen({Key? key}) : super(key: key);

  static final List<Consulta> consultas = [
    Consulta(
      nombrePaciente: 'Juan Pérez',
      numeroConsulta: 'C-001',
      resumen: 'Consulta de control cardiológico. Paciente estable.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'María López',
      numeroConsulta: 'C-002',
      resumen: 'Revisión pediátrica anual. Sin novedades.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Carlos Sánchez',
      numeroConsulta: 'C-003',
      resumen: 'Tratamiento dermatológico para acné.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Ana Torres',
      numeroConsulta: 'C-004',
      resumen: 'Consulta neurológica por migrañas.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Luis Gómez',
      numeroConsulta: 'C-005',
      resumen: 'Control ginecológico de rutina.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Sofía Ramírez',
      numeroConsulta: 'C-006',
      resumen: 'Revisión oftalmológica. Cambio de lentes.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Miguel Castro',
      numeroConsulta: 'C-007',
      resumen: 'Consulta traumatológica por dolor de rodilla.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Lucía Herrera',
      numeroConsulta: 'C-008',
      resumen: 'Evaluación psiquiátrica inicial.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Andrés Ruiz',
      numeroConsulta: 'C-009',
      resumen: 'Consulta urológica por infección urinaria.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Valentina Díaz',
      numeroConsulta: 'C-010',
      resumen: 'Control endocrinológico de tiroides.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Pedro Jiménez',
      numeroConsulta: 'C-011',
      resumen: 'Consulta de gastroenterología por dolor abdominal.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Laura Molina',
      numeroConsulta: 'C-012',
      resumen: 'Revisión de alergias estacionales.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Jorge Salas',
      numeroConsulta: 'C-013',
      resumen: 'Consulta de nefrología por insuficiencia renal.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Camila Ríos',
      numeroConsulta: 'C-014',
      resumen: 'Control de embarazo primer trimestre.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Ricardo Paredes',
      numeroConsulta: 'C-015',
      resumen: 'Consulta de reumatología por dolor articular.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Natalia Vargas',
      numeroConsulta: 'C-016',
      resumen: 'Evaluación nutricional inicial.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Esteban Silva',
      numeroConsulta: 'C-017',
      resumen: 'Consulta de otorrinolaringología por sinusitis.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Paula Medina',
      numeroConsulta: 'C-018',
      resumen: 'Control de presión arterial.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Tomás Fuentes',
      numeroConsulta: 'C-019',
      resumen: 'Consulta de hematología por anemia.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
    Consulta(
      nombrePaciente: 'Gabriela Soto',
      numeroConsulta: 'C-020',
      resumen: 'Revisión general post-operatoria.',
      pdfPreviewUrl: 'https://cdn-icons-png.flaticon.com/512/337/337946.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: consultas.length,
      itemBuilder: (context, index) {
        final consulta = consultas[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vista previa PDF
                Container(
                  width: 56,
                  height: 72,
                  margin: const EdgeInsets.only(right: 16),
                  child: Image.network(
                    consulta.pdfPreviewUrl,
                    fit: BoxFit.contain,
                  ),
                ),
                // Info de la consulta
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consulta.nombrePaciente,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'N° Consulta: ${consulta.numeroConsulta}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        consulta.resumen,
                        style: const TextStyle(fontSize: 15),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 