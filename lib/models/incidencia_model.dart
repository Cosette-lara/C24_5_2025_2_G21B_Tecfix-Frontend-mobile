class Incidencia {
  final int id;
  final String descripcion;
  final String urgencia;
  final String estado;
  final String fecha;
  final String salon;
  final String pabellon;
  final String tipo;
  final String? fotoCodigo;
  final String? fotoAveria;

  Incidencia(
      {required this.id,
      required this.descripcion,
      required this.urgencia,
      required this.estado,
      required this.fecha,
      required this.salon,
      required this.pabellon,
      required this.tipo,
      this.fotoCodigo,
      this.fotoAveria});

  factory Incidencia.fromJson(Map<String, dynamic> json) {
    return Incidencia(
      id: json['id_incidencia'] ?? 0,
      descripcion: json['descripcion'] ?? 'Sin descripción',
      urgencia: json['urgencia'] ?? 'Media',
      estado: json['nombre_estado'] ?? 'Desconocido',
      fecha: json['fecha_creacion'] ?? '',
      salon: json['nombre_salon'] ?? 'N/A',
      pabellon: json['nombre_pabellon'] ?? 'N/A',
      tipo: json['nombre_tipo'] ?? 'General',
      fotoCodigo: json['foto_codigo'],
      fotoAveria: json['foto_averia'],
    );
  }
}
