class Pabellon {
  final int id;
  final String nombre;

  Pabellon({required this.id, required this.nombre});

  factory Pabellon.fromJson(Map<String, dynamic> json) =>
      Pabellon(id: json['id_pabellon'], nombre: json['nombre_pabellon']);

  // VITAL: Para que el Dropdown sepa identificar el objeto
  @override
  bool operator ==(Object other) => other is Pabellon && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

class Salon {
  final int id;
  final String nombre;

  Salon({required this.id, required this.nombre});

  factory Salon.fromJson(Map<String, dynamic> json) =>
      Salon(id: json['id_salon'], nombre: json['nombre_salon']);

  // VITAL: Para que el Dropdown sepa identificar el objeto
  @override
  bool operator ==(Object other) => other is Salon && other.id == id;
  @override
  int get hashCode => id.hashCode;
}
