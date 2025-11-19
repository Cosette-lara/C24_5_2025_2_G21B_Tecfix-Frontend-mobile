import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Modelo para el historial de cambios 
class HistorialCambio {
  final String fecha;
  final String descripcion;
  final String actor;

  HistorialCambio({required this.fecha, required this.descripcion, required this.actor});

  factory HistorialCambio.fromJson(Map<String, dynamic> json) {
    String fechaFormateada = 'Fecha desconocida';
    if(json['fecha_cambio'] != null) {
      try {
        fechaFormateada = DateFormat('dd/MM/yyyy, hh:mm a').format(DateTime.parse(json['fecha_cambio']));
      } catch (e) { /* ignorar error */ }
    }
    
    return HistorialCambio(
      fecha: fechaFormateada,
      descripcion: json['descripcion_cambio'] ?? 'Sin descripción',
      actor: json['usuario_actor']?['nombre_completo'] ?? 'Sistema',
    );
  }
}

// Modelo completo que se pasará a la pantalla de detalle
class IncidenciaDetalle {
  final int id;
  final String descripcion;
  final String ubicacion;
  final String urgencia;
  final String fecha;
  final String estado;
  final Color colorEstado;
  final double? horasHombre;
  final List<String> fotos;
  final List<HistorialCambio> historial;

  IncidenciaDetalle({
    required this.id,
    required this.descripcion,
    required this.ubicacion,
    required this.urgencia,
    required this.fecha,
    required this.estado,
    required this.colorEstado,
    this.horasHombre,
    required this.fotos,
    required this.historial,
  });

  factory IncidenciaDetalle.fromJson(Map<String, dynamic> json) {
    String estadoNombre = json['estado']?['nombre_estado'] ?? 'Desconocido';
    Color color = Colors.grey;
    if (estadoNombre == 'En Progreso') color = Colors.blue;
    if (estadoNombre == 'Resuelto (Pendiente de Validación)') color = Colors.green;
    if (estadoNombre == 'Pendiente de Asignación') color = Colors.orange;
    if (estadoNombre == 'Validado y Cerrado') color = Colors.green[800]!;

    String fechaFormateada = 'Fecha desconocida';
    if(json['fecha_creacion'] != null) {
      try {
        fechaFormateada = DateFormat('dd/MM/yyyy, hh:mm a').format(DateTime.parse(json['fecha_creacion']));
      } catch (e) { /* ignorar error */ }
    }

    List<String> listaFotos = [];
    if (json['fotos'] != null) {
       listaFotos = List<String>.from(json['fotos'].map((foto) => foto['url_foto']));
    }
    
    List<HistorialCambio> listaHistorial = [];
    if (json['historial'] != null) {
       listaHistorial = List<HistorialCambio>.from(json['historial'].map((item) => HistorialCambio.fromJson(item)));
    }
    
    double? horas = json['horas_hombre'] != null ? double.tryParse(json['horas_hombre'].toString()) : null;

    return IncidenciaDetalle(
      id: json['id_incidencia'] ?? 0, 
      descripcion: json['descripcion'] ?? 'Sin descripción',
      ubicacion: json['ubicacion'] ?? 'Sin ubicación',
      urgencia: json['urgencia'] ?? 'No definida',
      fecha: fechaFormateada,
      estado: estadoNombre,
      colorEstado: color,
      horasHombre: horas,
      fotos: listaFotos,
      historial: listaHistorial,
    );
  }
}

// Modelo para el resumen del dashboard
class ResumenReportes {
  final int pendientes;
  final int resueltos;
  ResumenReportes({this.pendientes = 0, this.resueltos = 0});

  factory ResumenReportes.fromJson(Map<String, dynamic> json) {
    return ResumenReportes(
      pendientes: json['pendientes'] ?? 0,
      resueltos: json['resueltos'] ?? 0,
    );
  }
}