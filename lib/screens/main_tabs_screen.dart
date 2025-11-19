import 'package:flutter/material.dart';
// Añade los imports para todas las pantallas
import 'package:tecfix_frontend_mobile/screens/inicio_screen.dart';
import 'package:tecfix_frontend_mobile/screens/reportar_screen.dart';
import 'package:tecfix_frontend_mobile/screens/historial_screen.dart';
import 'package:tecfix_frontend_mobile/screens/perfil_screen.dart';
// --- FIN DE CORRECCIÓN ---

class MainTabsScreen extends StatefulWidget {
  const MainTabsScreen({Key? key}) : super(key: key);

  @override
  _MainTabsScreenState createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreen> {
  int _selectedIndex = 0; // 0 = Inicio

  // La lista de pantallas ya no puede ser 'static const'
  // porque necesitamos pasarle una función a InicioScreen.
  late List<Widget> _widgetOptions;

  // Creamos un controlador para las pestañas
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Creamos la lista de pantallas aquí
    // Le pasamos la función _changeTab a InicioScreen
    _widgetOptions = <Widget>[
      InicioScreen(onTabChange: _changeTab), 
      ReportarScreen(),
      HistorialScreen(),
      PerfilScreen(),
    ];
  }

  // Esta es la función que la pantalla 'Inicio' llamará
  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Usamos DefaultTabController para que InicioScreen pueda llamar a 'DefaultTabController.of(context).animateTo(index)'
    return DefaultTabController(
      length: 4, // El número de pestañas
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_comment_outlined),
              activeIcon: Icon(Icons.add_comment),
              label: 'Reportar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Historial',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          onTap: _changeTab, // El onTap de la barra también usa la misma función
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}