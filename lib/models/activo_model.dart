class Activo {
  final int id;
  final String nombre;
  final String codigo;
  Activo({required this.id, required this.nombre, required this.codigo});

  factory Activo.fromJson(Map<String, dynamic> json) => Activo(
        id: json['id_activo'],
        nombre: json['nombre_activo'],
        codigo: json['codigo_patrimonial'],
      );
}
