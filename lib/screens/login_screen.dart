import 'package:flutter/material.dart';
import '../services/auth_service.dart';
// 👇 ESTA LÍNEA ES LA QUE TE FALTA. AGREGA ESTO:
import 'main_tabs_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService(); // Instancia del servicio
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);

    // Llamada al servicio de login
    final success = await _authService.login(_emailCtrl.text, _passCtrl.text);

    setState(() => _isLoading = false);

    if (success) {
      // Navegar a la pantalla principal (MainTabsScreen)
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => MainTabsScreen()) // Ahora sí lo reconocerá
          );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error de credenciales')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_pin, size: 80, color: Color(0xFF4A90E2)),
            SizedBox(height: 20),
            Text('Usuario General',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Ingresa con tus credenciales de TECSUP',
                style: TextStyle(color: Colors.grey)),
            SizedBox(height: 40),
            TextField(
              controller: _emailCtrl,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: Icon(Icons.email_outlined),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: Icon(Icons.lock_outline),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
