import 'package:flutter/material.dart';
import 'inicio_screen.dart';
import 'reportar_screen.dart';
import 'historial_screen.dart';
import 'perfil_screen.dart';

class MainTabsScreen extends StatefulWidget {
  @override
  _MainTabsScreenState createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _index = 0;

  void _setIndex(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      InicioScreen(onTabChange: _setIndex),
      ReportarScreen(),
      HistorialScreen(),
      PerfilScreen()
    ];

    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _setIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: 'Reportar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
