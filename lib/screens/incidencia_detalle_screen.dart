import 'package:flutter/material.dart';
import '../models/incidencia_model.dart';
import '../config/constants.dart';

class IncidenciaDetalleScreen extends StatelessWidget {
  final Incidencia incidencia;
  IncidenciaDetalleScreen({required this.incidencia});

  String _url(String? f) {
    if (f == null) return '';
    return '${Constants.baseUrl.replaceAll('/api', '')}/uploads/$f';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle')),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Text('Estado: ${incidencia.estado}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Ubicación: ${incidencia.pabellon} - ${incidencia.salon}'),
          Text('Tipo: ${incidencia.tipo}'),
          Text('Descripción: ${incidencia.descripcion}'),
          SizedBox(height: 20),
          Text('Fotos:', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(children: [
            if (incidencia.fotoCodigo != null)
              Expanded(child: Image.network(_url(incidencia.fotoCodigo))),
            SizedBox(width: 10),
            if (incidencia.fotoAveria != null)
              Expanded(child: Image.network(_url(incidencia.fotoAveria))),
          ]),
        ],
      ),
    );
  }
}
