import 'package:flutter/material.dart';
import '../../layout/main_layout.dart';
import '../services/firebase_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = FirebaseAuthService();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    try {
      final user = await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        bool isAdmin = await _authService.isUserAdmin(user.uid);
        
        if (isAdmin && mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainLayout()), // Tu menú de Admin
          );
        } else {
          await _authService.signOut();
          if (mounted) _showError('Acceso Denegado: No eres administrador.');
        }
      }
    } catch (e) {
      if (mounted) _showError('Credenciales incorrectas');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Fondo oscuro tech
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.security, size: 60, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text('SMART SYNC', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
              const Text('Admin Portal', style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Correo Electrónico', labelStyle: TextStyle(color: Colors.white54)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Contraseña', labelStyle: TextStyle(color: Colors.white54)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('ACCEDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
