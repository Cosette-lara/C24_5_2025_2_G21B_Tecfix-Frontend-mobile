import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/incidencia_model.dart';
import 'incidencia_detalle_screen.dart';

class InicioScreen extends StatefulWidget {
  final Function(int) onTabChange;
  InicioScreen({required this.onTabChange});
  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  String _name = '';
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then(
        (p) => setState(() => _name = p.getString('userName') ?? 'Usuario'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hola, $_name'), elevation: 0),
      body: FutureBuilder<List<Incidencia>>(
        future: _api.getMisReportes(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          final list = snap.data ?? [];
          final pending = list.where((i) => i.estado == 'Pendiente').length;
          final solved = list
              .where((i) => i.estado == 'Resuelto' || i.estado == 'Cerrado')
              .length;

          return ListView(
            padding: EdgeInsets.all(20),
            children: [
              // Tarjeta Resumen
              Row(children: [
                _statCard('Pendientes', '$pending', Colors.orange),
                SizedBox(width: 15),
                _statCard('Resueltos', '$solved', Colors.green),
              ]),
              SizedBox(height: 20),
              // Botón Reportar
              ElevatedButton.icon(
                onPressed: () => widget.onTabChange(1),
                icon: Icon(Icons.add),
                label: Text('REPORTAR INCIDENCIA'),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50)),
              ),
              SizedBox(height: 30),
              Text('Recientes',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (list.isEmpty)
                Padding(
                    padding: EdgeInsets.all(20), child: Text('Sin reportes')),
              ...list.take(3).map((item) => Card(
                    child: ListTile(
                      title: Text(item.descripcion,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(item.estado),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  IncidenciaDetalleScreen(incidencia: item))),
                    ),
                  ))
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String val, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(val,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: color)),
        ]),
      ),
    );
  }
}
