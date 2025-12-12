class Usuario {
  final int id;
  final String nombre;
  final String email;
  Usuario({required this.id, required this.nombre, required this.email});
  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
      id: json['id_usuario'],
      nombre: json['nombre_completo'],
      email: json['email']);
}
