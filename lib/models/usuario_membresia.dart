class UsuarioMembresia {
  final int idUsuarioMembresia;
  final String nombreMembresia;
  final String nombreUsuario;
  final String fechaInicio;
  final String fechaFin;
  final String estado;

  UsuarioMembresia({
    required this.idUsuarioMembresia,
    required this.nombreMembresia,
    required this.nombreUsuario,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
  });

  factory UsuarioMembresia.fromJson(Map<String, dynamic> json) {
    return UsuarioMembresia(
      idUsuarioMembresia: json['id_usuario_membresia'],
      nombreMembresia: json['nombre_membresia'],
      nombreUsuario: json['nombre_usuario'],
      fechaInicio: json['fecha_inicio'].toString(),
      fechaFin: json['fecha_fin'].toString(),
      estado: json['estado'],
    );
  }
}