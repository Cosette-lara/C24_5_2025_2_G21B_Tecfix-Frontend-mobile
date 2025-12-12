import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/incidencia_model.dart';
import 'incidencia_detalle_screen.dart';

class HistorialScreen extends StatelessWidget {
  final _api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historial')),
      body: FutureBuilder<List<Incidencia>>(
        future: _api.getMisReportes(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          final list = snap.data ?? [];
          if (list.isEmpty) return Center(child: Text('Sin reportes'));

          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (ctx, i) {
              final item = list[i];
              return ListTile(
                title: Text(item.descripcion),
                subtitle: Text(item.estado),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            IncidenciaDetalleScreen(incidencia: item))),
              );
            },
          );
        },
      ),
    );
  }
}
