// Archivo: lib/screens/perfil_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Importa la pantalla de Login para la lógica de "Cerrar Sesión"
import 'package:tecfix_frontend_mobile/screens/login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _nombre = 'Cargando...';
  String _email = 'Cargando...';

  // Estados para los Toggles (basado en el prototipo)
  bool _notificacionesPush = true;
  bool _alertasUrgentes = true;
  bool _compartirUbicacion = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Carga los datos guardados en el Login desde SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombre = prefs.getString('usuario_nombre') ?? 'Nombre no encontrado';
      _email = prefs.getString('usuario_email') ?? 'email@tecsup.edu.pe';
    });
  }

  // --- Lógica de Cerrar Sesión ---
  Future<void> _cerrarSesion() async {
    // 1. Borrar los datos guardados en el dispositivo
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Borra todo (token, id, nombre, email)

    // 2. Navegar de vuelta a la pantalla de Login
    // Se usa 'pushAndRemoveUntil' para que el usuario no pueda "retroceder"
    // a la pantalla de Perfil una vez que cerró sesión.
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (ctx) => const LoginScreen()),
      (Route<dynamic> route) => false, // Elimina todas las rutas anteriores
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        automaticallyImplyLeading: false, // Oculta el botón de "atrás"
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección: Cabecera de Perfil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              color: Colors.grey[100],
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).primaryColorLight,
                    child: Text(
                      _nombre.isNotEmpty ? _nombre[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_nombre, style: Theme.of(context).textTheme.titleLarge),
                  Text(_email, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),

            // Sección: Notificaciones (basada en el prototipo)
            _buildSectionHeader('Notificaciones'),
            SwitchListTile(
              secondary: const Icon(Icons.notifications_active_outlined),
              title: const Text('Notificaciones Push'),
              subtitle: const Text('Recibir actualizaciones por correo'),
              value: _notificacionesPush,
              onChanged: (val) => setState(() => _notificacionesPush = val),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.warning_amber_rounded),
              title: const Text('Alertas Urgentes'),
              subtitle: const Text('Notificaciones inmediatas para casos críticos'),
              value: _alertasUrgentes,
              onChanged: (val) => setState(() => _alertasUrgentes = val),
            ),

            // Sección: Privacidad y Seguridad (basada en el prototipo)
            _buildSectionHeader('Privacidad y Seguridad'),
            SwitchListTile(
              secondary: const Icon(Icons.location_on_outlined),
              title: const Text('Compartir Ubicación'),
              subtitle: const Text('Permitir geolocalización en reportes'),
              value: _compartirUbicacion,
              onChanged: (val) => setState(() => _compartirUbicacion = val),
            ),

            const Divider(height: 32),
            // Botón: Cerrar Sesión
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                onPressed: _cerrarSesion,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para los encabezados de sección
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
