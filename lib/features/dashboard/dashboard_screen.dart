import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bienvenido al Dashboard', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildStatCard('Total Usuarios', '1,200', Icons.people, Colors.purpleAccent),
              const SizedBox(width: 24),
              _buildStatCard('Asistencias Hoy', '345', Icons.check_circle, Colors.greenAccent),
              const SizedBox(width: 24),
              _buildStatCard('Alertas GPS', '12', Icons.warning, Colors.orangeAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
