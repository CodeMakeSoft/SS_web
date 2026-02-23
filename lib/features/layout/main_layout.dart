import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../users/users_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    UsersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar de Navegación
          NavigationRail(
            backgroundColor: const Color(0xFF0F172A),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            extended: MediaQuery.of(context).size.width >= 800, // Expandir si hay espacio
            indicatorColor: Colors.blueAccent.withOpacity(0.5),
            unselectedIconTheme: const IconThemeData(color: Colors.white70),
            selectedIconTheme: const IconThemeData(color: Colors.white),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
            selectedLabelTextStyle: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Icon(Icons.dashboard_customize, size: 40, color: Colors.blueAccent),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Usuarios'),
              ),
            ],
          ),
          
          const VerticalDivider(thickness: 1, width: 1, color: Colors.blueGrey),
          
          // Contenido Principal
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
