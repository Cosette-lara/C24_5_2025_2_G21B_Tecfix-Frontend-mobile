// Archivo: lib/screens/inicio_screen.dart
// (Versión completa con todos los errores corregidos)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:tecfix_frontend_mobile/utils/constants.dart';
import 'package:tecfix_frontend_mobile/screens/incidencia_detalle_screen.dart';

// --- ¡CORREGIDO! ---
// Importa los modelos desde el archivo central
import '../models/incidencia_model.dart';

// --- WIDGET PRINCIPAL ---

class InicioScreen extends StatefulWidget {
  // Función de callback para cambiar de pestaña en 'main_tabs_screen.dart'
  final Function(int) onTabChange;
  
  const InicioScreen({Key? key, required this.onTabChange}) : super(key: key);

  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  // El FutureBuilder usará esta variable
  Future<Map<String, dynamic>>? _dashboardData;
  String _nombreUsuario = 'Usuario'; // Valor por defecto

  @override
  void initState() {
    super.initState();
    // Carga el nombre de usuario y *asigna* el Future
    _loadUserDataAndFetchDashboard();
  }

  // Carga el nombre de usuario y luego asigna la tarea de carga de datos
  Future<void> _loadUserDataAndFetchDashboard() async {
    final prefs = await SharedPreferences.getInstance();
    // Actualiza el nombre de usuario para el saludo
    setState(() {
      _nombreUsuario = prefs.getString('usuario_nombre')?.split(' ')[0] ?? 'Usuario';
    });
    // Asigna el Future a la variable. El FutureBuilder lo ejecutará.
    _dashboardData = _fetchDashboardData();
  }

  // --- LÓGICA DE CONEXIÓN AL BACKEND ---
  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final idUsuario = prefs.getInt('usuario_id');

    if (token == null || idUsuario == null) {
      throw Exception('Usuario no autenticado.');
    }

    final headers = {
      'Content-Type': 'application/json',
      'x-auth-token': token,
    };

    try {
      // 1. Crea las tareas (Futures)
      final resResumenFuture = http.get(Uri.parse('$API_URL/api/incidencias/resumen/$idUsuario'), headers: headers);
      final resUltimasFuture = http.get(Uri.parse('$API_URL/api/incidencias/ultimas/$idUsuario'), headers: headers);

      // 2. Ejecútalas en paralelo
      final responses = await Future.wait([
        resResumenFuture,
        resUltimasFuture
      ]);

      // 3. Procesa los resultados
      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final ResumenReportes resumen = ResumenReportes.fromJson(jsonDecode(responses[0].body));
        final List<IncidenciaDetalle> ultimas = (jsonDecode(responses[1].body) as List)
            .map((data) => IncidenciaDetalle.fromJson(data)) 
            .toList();
        
        return {'resumen': resumen, 'ultimas': ultimas};
      } else {
        throw Exception('Error al cargar datos del dashboard');
      }
    } catch (e) {
      // Relanza el error para que el FutureBuilder lo capture
      throw Exception(e.toString());
    }
  }
  
  // Función para el 'Pull-to-Refresh'
  Future<void> _onRefresh() async {
    // Simplemente reasigna el Future.
    setState(() {
      _dashboardData = _fetchDashboardData();
    });
  }

  // --- NAVEGACIÓN A PANTALLA DE DETALLE ---
  void _navegarADetalle(IncidenciaDetalle reporte) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => IncidenciaDetalleScreen(incidencia: reporte),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene los estilos de texto del tema
    final textTheme = Theme.of(context).textTheme;
    final titleLargeBold = textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      // --- AppBar basada en el prototipo ---
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reportar Incidencia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Hola, $_nombreUsuario', style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.8))),
          ],
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 80, 
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardData,
        builder: (context, snapshot) {
          
          // --- 1. Estado de Carga ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          // --- 2. Estado de Error ---
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, color: Colors.red, size: 50),
                    SizedBox(height: 16),
                    Text(
                      'Error al cargar datos:\n${snapshot.error}', 
                      textAlign: TextAlign.center, 
                      style: TextStyle(color: Colors.red[700], fontSize: 16)
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Icon(Icons.refresh),
                      onPressed: _onRefresh,
                      label: Text('Reintentar'),
                    )
                  ],
                ),
              ),
            );
          }
          
          // --- 3. Estado de Éxito ---
          if (snapshot.hasData) {
            final ResumenReportes resumen = snapshot.data!['resumen'];
            final List<IncidenciaDetalle> ultimas = snapshot.data!['ultimas'];

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- Tarjeta "Reportar Nueva Incidencia" ---
                    _buildGenericCard(
                      context: context,
                      title: 'Reportar Nueva Incidencia',
                      subtitle: '¿Encontraste algo problemático? Repórtalo aquí.',
                      icon: Icons.add,
                      buttonText: 'Reportar',
                      onButtonPressed: () {
                        // Llama a la función del widget padre (MainTabsScreen)
                        // para cambiar a la pestaña 1 (Reportar)
                        widget.onTabChange(1); 
                      },
                    ),
                    SizedBox(height: 16),

                    // --- Tarjeta "Mis Reportes" (Ver Historial) ---
                    _buildGenericCard(
                      context: context,
                      title: 'Mis Reportes',
                      subtitle: 'Ver historial de incidencias reportadas.',
                      icon: Icons.history,
                      buttonText: 'Ver Historial',
                      onButtonPressed: () {
                        // Cambia a la pestaña 2 (Historial)
                        widget.onTabChange(2);
                      },
                    ),
                    SizedBox(height: 24),
                    
                    // --- Sección "Resumen de Mis Reportes" (RF-03) ---
                    Text('Resumen de Mis Reportes', style: titleLargeBold),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildResumenCard(resumen.pendientes.toString(), 'Pendientes', Theme.of(context).primaryColor),
                        SizedBox(width: 16),
                        _buildResumenCard(resumen.resueltos.toString(), 'Resueltos', Colors.green[700]!),
                      ],
                    ),
                    SizedBox(height: 24),

                    // --- Sección "Últimas Incidencias" (RF-03) ---
                    Row(
                      children: [
                        Icon(Icons.remove_red_eye_outlined, color: Colors.grey[700], size: 20),
                        SizedBox(width: 8),
                        Text('Últimas Incidencias', style: titleLargeBold),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    ultimas.isEmpty
                        ? Card(
                            elevation: 0, 
                            color: Colors.grey[50], 
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey[200]!),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  '¡Felicidades, no tienes reportes activos!',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: ultimas.map((inc) => _buildIncidenciaCard(context, inc)).toList(),
                          ),
                  ],
                ),
              ),
            );
          }
          // Estado por defecto si algo inesperado ocurre
          return Center(child: Text('No hay datos disponibles.'));
        },
      ),
    );
  }

  // --- Widgets Auxiliares (para construir las tarjetas) ---
  
  Widget _buildGenericCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final titleLargeBold = textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold);

    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: titleLargeBold),
                  SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: onButtonPressed,
              icon: Icon(icon, size: 20),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                // Hereda los colores del tema principal
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResumenCard(String numero, String titulo, Color color) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                numero,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
              ),
              SizedBox(height: 4),
              Text(titulo, style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIncidenciaCard(BuildContext context, IncidenciaDetalle inc) {
    // Lógica de colores basada en el prototipo
    Color colorEstado = inc.colorEstado; 
    String estadoTexto = inc.estado;

    if (inc.estado == 'Pendiente de Asignación') { 
      colorEstado = Colors.grey[600]!; 
      estadoTexto = 'Sin Asignar'; // Texto del prototipo
    } else if (inc.estado == 'Validado y Cerrado') {
      estadoTexto = 'Resuelto'; // Texto del prototipo
    }

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!), // Borde ligero
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        title: Text(
          inc.descripcion, 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inc.ubicacion, style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 4),
            Text(inc.fecha, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
        trailing: Chip(
          label: Text(estadoTexto, style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          backgroundColor: colorEstado,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onTap: () {
          _navegarADetalle(inc); // Navegamos a la pantalla de detalle
        },
      ),
    );
  }
}