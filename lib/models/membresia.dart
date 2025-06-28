class Membresia {
  final int idMembresia; 
  final String nombre;
  final int duracionDias; 
  final int costoTotal; 
  final String descripcion;

  Membresia({
    required this.idMembresia,
    required this.nombre,
    required this.duracionDias,
    required this.costoTotal,
    required this.descripcion,
  });


  // Convierte un JSON en un objeto Membresia
  factory Membresia.fromJson(Map<String, dynamic> json) {
    return Membresia(
      idMembresia: json['id_membresia'], 
      nombre: json['nombre'],
      duracionDias: json['duracion_dias'], 
      costoTotal: json['costo_total'], 
      descripcion: json['descripcion'],
    );
  }

  // Convierte un objeto Membresia en un JSON
  Map<String, dynamic> toJson() {
    return {
      'id_membresia': idMembresia,
      'nombre': nombre,
      'duracion_dias': duracionDias,
      'costo_total': costoTotal,
      'descripcion': descripcion,
    };
  }
}

