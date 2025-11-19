// Archivo: lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importa tus pantallas
import 'package:tecfix_frontend_mobile/screens/login_screen.dart';
import 'package:tecfix_frontend_mobile/screens/main_tabs_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  /**
   * Verifica si existe un token de sesión guardado en el dispositivo.
   * Esta es la lógica de "Mantener sesión iniciada".
   */
  Future<bool> _verificarToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Busca el token que guardamos en 'login_screen.dart'
    final token = prefs.getString('token'); 
    
    if (token != null && token.isNotEmpty) {
      // El usuario ya inició sesión
      return true;
    }
    // No hay token, el usuario debe iniciar sesión
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Define el color primario de TECSUP para toda la app
    final MaterialColor tecsupBlue = MaterialColor(
      0xFF1976D2, // Azul principal
      <int, Color>{
        50: Color(0xFFE3F2FD),
        100: Color(0xFFBBDEFB),
        200: Color(0xFF90CAF9),
        300: Color(0xFF64B5F6),
        400: Color(0xFF42A5F5),
        500: Color(0xFF2196F3),
        600: Color(0xFF1E88E5),
        700: Color(0xFF1976D2), // Color para botones y barras
        800: Color(0xFF1565C0), // Color más oscuro para la barra de estado
        900: Color(0xFF0D47A1),
      },
    );

    return MaterialApp(
      title: 'TECSUP Mantenimiento',
      theme: ThemeData(
        primarySwatch: tecsupBlue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        
        // Estilo de la barra de AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: tecsupBlue[800], // Barra de título más oscura
          foregroundColor: Colors.white, // Texto y iconos en blanco
          elevation: 0.5,
        ),
        
        // Estilo de botones elevados (CORREGIDO)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: tecsupBlue[700], // <-- CORREGIDO
            foregroundColor: Colors.white, // <-- CORREGIDO
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      
      // --- LÓGICA DE NAVEGACIÓN PRINCIPAL ---
      home: FutureBuilder<bool>(
        future: _verificarToken(), // Revisa el token al iniciar
        builder: (context, snapshot) {
          
          // 1. Mientras verifica, muestra un 'spinner' de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. Si el snapshot tiene data 'true' (token existe)
          if (snapshot.hasData && snapshot.data == true) {
            // Vaya a la pantalla principal (Dashboard)
            return MainTabsScreen();
          }

          // 3. Si no hay token (snapshot.data es false o nulo)
          // Vaya al Login
          return LoginScreen();
        },
      ),
      
      // (Opcional) Define rutas con nombre para una navegación más limpia
      routes: {
        '/login': (ctx) => LoginScreen(),
        '/home': (ctx) => MainTabsScreen(),
      },
    );
  }
}