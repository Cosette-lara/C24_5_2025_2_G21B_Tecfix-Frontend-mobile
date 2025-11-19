// Archivo: lib/screens/incidencia_detalle_screen.dart
// (Versión corregida: importa modelos centralizados)

import 'package:flutter/material.dart';
import 'package:tecfix_frontend_mobile/utils/constants.dart';

// --- ¡IMPORTA LOS MODELOS DESDE EL ARCHIVO CENTRAL! ---
import '../models/incidencia_model.dart';

// -------------------------------------------------
// ¡LAS CLASES 'IncidenciaDetalle' Y 'HistorialCambio' SE BORRARON DE AQUÍ!
// -------------------------------------------------

class IncidenciaDetalleScreen extends StatefulWidget {
  final IncidenciaDetalle incidencia;

  const IncidenciaDetalleScreen({Key? key, required this.incidencia}) : super(key: key);

  @override
  _IncidenciaDetalleScreenState createState() => _IncidenciaDetalleScreenState();
}

class _IncidenciaDetalleScreenState extends State<IncidenciaDetalleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2 pestañas
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Incidente'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'DETALLES'),
            Tab(text: 'HISTORIAL'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetallesTab(widget.incidencia),
          _buildHistorialTab(widget.incidencia.historial),
        ],
      ),
    );
  }

  /// Pestaña 1: Muestra los detalles de la incidencia
  Widget _buildDetallesTab(IncidenciaDetalle inc) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Sección de Foto ---
          if (inc.fotos.isNotEmpty)
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage('$API_URL/${inc.fotos[0]}'),
                  fit: BoxFit.cover,
                  onError: (err, stack) => const Center(child: Icon(Icons.broken_image, size: 50)),
                ),
              ),
            )
          else
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey[400]),
            ),
          const SizedBox(height: 24),
          
          Text('DESCRIPCIÓN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(inc.descripcion, style: textTheme.headlineSmall),
          const SizedBox(height: 24),
          const Divider(),
          
          _buildInfoRow(Icons.flag_outlined, 'ESTADO', '', chip: Chip(
            label: Text(inc.estado, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            backgroundColor: inc.colorEstado,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          )),
          _buildInfoRow(Icons.location_on_outlined, 'UBICACIÓN', inc.ubicacion),
          _buildInfoRow(Icons.calendar_today_outlined, 'FECHA DE REPORTE', inc.fecha),
          _buildInfoRow(Icons.priority_high_rounded, 'URGENCIA', inc.urgencia),
          if (inc.horasHombre != null)
            _buildInfoRow(Icons.timer_outlined, 'HORAS HOMBRE REGISTRADAS', '${inc.horasHombre} horas'),
        ],
      ),
    );
  }

  /// Pestaña 2: Muestra el historial de cambios (RF-13)
  Widget _buildHistorialTab(List<HistorialCambio> historial) {
     if (historial.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Aún no hay historial de cambios.', style: TextStyle(color: Colors.grey[600])),
          ],
        )
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: historial.length,
      itemBuilder: (context, index) {
        final item = historial[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColorLight,
              child: Icon(Icons.history, color: Theme.of(context).primaryColor),
            ),
            title: Text(item.descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Por: ${item.actor}\n${item.fecha}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  /// Widget auxiliar para las filas de información en la pestaña "Detalles"
  Widget _buildInfoRow(IconData icon, String label, String value, {Widget? chip}) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 4),
                if (chip != null) 
                  Align(alignment: Alignment.centerLeft, child: chip) 
                else 
                  Text(value, style: textTheme.titleMedium),
              ],
            ),
          )
        ],
      ),
    );
  }
}