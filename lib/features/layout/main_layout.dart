import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/services/firebase_auth_service.dart';
import '../auth/presentation/login_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../users/users_screen.dart';
// import '../events/events_screen.dart'; // <--- Lo crearemos después
import '../sudo_roles/sudo_roles_screen.dart'; 

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  String _userRole = 'user'; // Por defecto escondemos todo
  final _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  // Averiguar si somos Admin o Dios (Sudo)
  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final role = await _authService.getUserRole(user);
      if (mounted) {
        setState(() {
          _userRole = role; // Actualiza el nivel de poderes
        });
      }
    }
  }

  void _handleLogout() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  // ESTA ES LA LISTA DE LAS PANTALLAS FINALES (Lado derecho de la Web)
  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen(); // Tablero Rápido
      case 1:
        return const UsersScreen(); // Check-in Kit/QR
      case 2:
        return const Center(child: Text("Pantalla de Crear Carrera Eventos.")); // EventsScreen vacía
      case 3:
        return const SudoRolesScreen(); // SudoRoles screen
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Fondo de bóveda tech
      body: Row(
        children: [
          // MENÚ LATERAL IZQUIERDO (SIDEBAR)
          Container(
            width: 250, // Grosor menú
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset('assets/images/logo.png', height: 60),
                const SizedBox(height: 10),
                const Text('SMART SYNC Admin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(color: Colors.white24, height: 40),
                
                // --- BOTONES GENERALES DE ADMINS ---
                _SidebarButton(
                  icon: Icons.dashboard, title: 'Dashboard', 
                  isActive: _selectedIndex == 0, onTap: () => setState(() => _selectedIndex = 0),
                ),
                _SidebarButton(
                  icon: Icons.qr_code_scanner, title: 'Acreditación / Kits', 
                  isActive: _selectedIndex == 1, onTap: () => setState(() => _selectedIndex = 1),
                ),
                _SidebarButton(
                  icon: Icons.map, title: 'Gestión Evento Vivo', 
                  isActive: _selectedIndex == 2, onTap: () => setState(() => _selectedIndex = 2),
                ),

                const Spacer(), // Empujar botones hasta abajo

                // --- BOTÓN EXCLUSIVO (SOLO DIOS LO VE) ---
                if (_userRole == 'sudo') ...[
                  const Divider(color: Colors.white24),
                  _SidebarButton(
                    icon: Icons.admin_panel_settings, title: 'Permisos', 
                    isActive: _selectedIndex == 3, onTap: () => setState(() => _selectedIndex = 3),
                    isSudoColor: true, // Color naranja peligro
                  ),
                ],

                const Divider(color: Colors.white24),
                // Botón genérico salir
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
                  title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
                  onTap: _handleLogout,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          
          // LADO DERECHO GIGANTE (Contenido variable)
          Expanded(
            child: Container(
              color: const Color(0xFF0F172A),
              child: _getSelectedScreen(),
            ),
          )
        ],
      ),
    );
  }
}

// (Widget de Micro-diseño para el botón para no repetir código visual)
class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isActive;
  final VoidCallback onTap;
  final bool isSudoColor;

  const _SidebarButton({required this.icon, required this.title, required this.isActive, required this.onTap, this.isSudoColor = false});

  @override
  Widget build(BuildContext context) {
    Color selectedColor = isSudoColor ? Colors.orangeAccent : Colors.blueAccent;
    return Container(
      color: isActive ? Colors.white.withOpacity(0.05) : Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: isActive ? selectedColor : Colors.white54),
        title: Text(title, style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        onTap: onTap,
        shape: Border(left: BorderSide(color: isActive ? selectedColor : Colors.transparent, width: 4)),
      ),
    );
  }
}
