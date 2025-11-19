// Archivo: lib/screens/historial_screen.dart
// (Versión corregida: importa modelos, no los define)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tecfix_frontend_mobile/utils/constants.dart';
import 'package:intl/intl.dart';

// Importa la pantalla de detalle
import 'incidencia_detalle_screen.dart';
// --- ¡IMPORTA LOS MODELOS DESDE EL ARCHIVO CENTRAL! ---
import '../models/incidencia_model.dart';

// -------------------------------------------------
// ¡LAS CLASES 'IncidenciaDetalle' Y 'HistorialCambio' SE BORRARON DE AQUÍ!
// -------------------------------------------------

// --- WIDGET PRINCIPAL ---

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late Future<List<IncidenciaDetalle>> _historialFuture;

  @override
  void initState() {
    super.initState();
    _historialFuture = _fetchHistorial();
  }
  
  // Lógica de Conexión al Backend (RF-03)
  Future<List<IncidenciaDetalle>> _fetchHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idUsuario = prefs.getInt('usuario_id');

    if (token == null || idUsuario == null) {
      throw Exception('Usuario no autenticado.');
    }
    
    final headers = { 'Content-Type': 'application/json', 'x-auth-token': token };

    final response = await http.get(Uri.parse('$API_URL/api/incidencias/usuario/$idUsuario'), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      // Ahora usa la clase 'IncidenciaDetalle' importada
      return data.map((json) => IncidenciaDetalle.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar el historial.');
    }
  }
  
  Future<void> _onRefresh() async {
    setState(() {
      _historialFuture = _fetchHistorial();
    });
  }

  // Navegación a Pantalla de Detalle
  void _navegarADetalle(IncidenciaDetalle reporte) {
    Navigator.of(context).push(
      MaterialPageRoute(
        // Ahora 'reporte' es del tipo correcto
        builder: (ctx) => IncidenciaDetalleScreen(incidencia: reporte),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reportes (Historial)'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<IncidenciaDetalle>>(
        future: _historialFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
             return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Reintentar'),
                  )
                ],
              ),
            );
          }
          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final reportes = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: reportes.length,
                itemBuilder: (context, index) {
                  final reporte = reportes[index];
                  
                  // Lógica de estilo para el chip
                  Color colorEstado = reporte.colorEstado; 
                  String estadoTexto = reporte.estado;
                  if (reporte.estado == 'Pendiente de Asignación') { 
                    colorEstado = Colors.grey[600]!; 
                    estadoTexto = 'Sin Asignar';
                  } else if (reporte.estado == 'Validado y Cerrado') {
                    estadoTexto = 'Resuelto';
                  }

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12.0),
                      leading: reporte.fotos.isNotEmpty 
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4.0),
                            child: Image.network(
                              '$API_URL/${reporte.fotos[0]}',
                              width: 50, 
                              height: 50, 
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
                            ),
                          ) 
                        : Icon(Icons.image_not_supported, size: 50, color: Colors.grey[400]),
                      title: Text(reporte.descripcion, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${reporte.ubicacion}\n${reporte.fecha}'),
                      isThreeLine: true,
                      trailing: Chip(
                        label: Text(estadoTexto, style: const TextStyle(color: Colors.white, fontSize: 10)),
                        backgroundColor: colorEstado,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      ),
                      onTap: () {
                        _navegarADetalle(reporte);
                      },
                    ),
                  );
                },
              ),
            );
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text('Aún no has enviado reportes.', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
              ],
            )
          );
        },
      ),
    );
  }
}