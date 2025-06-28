class Usuario {
  final int idUsuario;
  final String nombre;
  final String email;
  final String password;
  final int idRol;
  final String imagen;
  final String googleId;
  final String proveedor;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.email,
    required this.password,
    required this.idRol,
    required this.imagen,
    required this.googleId,
    required this.proveedor,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idUsuario: json['idUsuario'] ?? 0,
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      idRol: json['idRol'] ?? 0,
      imagen: json['imagen'] ?? '',
      googleId: json['googleId'] ?? '',
      proveedor: json['proveedor'] ?? '',
    );
  }
}