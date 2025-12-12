class TipoIncidencia {
  final int id;
  final String nombre;

  TipoIncidencia({required this.id, required this.nombre});

  factory TipoIncidencia.fromJson(Map<String, dynamic> json) =>
      TipoIncidencia(id: json['id_tipo'], nombre: json['nombre_tipo']);

  @override
  bool operator ==(Object other) => other is TipoIncidencia && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
