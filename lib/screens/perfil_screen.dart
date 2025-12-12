import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class PerfilScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Center(
        child: ElevatedButton.icon(
          icon: Icon(Icons.exit_to_app),
          label: Text('Cerrar Sesión'),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => LoginScreen()), (r) => false);
          },
        ),
      ),
    );
  }
}
