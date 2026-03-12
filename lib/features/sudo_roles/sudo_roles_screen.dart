import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SudoRolesScreen extends StatelessWidget {
  const SudoRolesScreen({super.key});

  Future<void> _updateUserRole(BuildContext context, String uid, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'role': newRole,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso actualizado exitosamente.'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error actualizando permiso: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Asignación de Permisos (Nivel Sudo)'),
        backgroundColor: const Color(0xFF1E293B),
      ),
      // Escuchamos la colección Worldwide 'users' en vivo
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error al cargar datos.'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aún no hay usuarios en la plataforma.'));
          }

          final users = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Dibujando la Tabla Administrativa
              DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFF1E293B)),
                columns: const [
                  DataColumn(label: Text('Nombre/Rider', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
                  DataColumn(label: Text('Correo Electrónico', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
                  DataColumn(label: Text('Nivel de Poder (Rol)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent))),
                ],
                rows: users.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final role = data['role'] ?? 'user';
                  final email = data['email'] ?? 'Oculto';
                  final displayName = data['displayName'] ?? 'Atleta';
                  final uid = doc.id;

                  return DataRow(cells: [
                    DataCell(Text(displayName, style: const TextStyle(color: Colors.white))),
                    DataCell(Text(email, style: const TextStyle(color: Colors.white70))),
                    DataCell(
                      // El selector rápido para que el Sudo cambie los poderes
                      DropdownButton<String>(
                        value: role,
                        dropdownColor: const Color(0xFF1E293B),
                        style: TextStyle(color: role == 'super_admin' ? Colors.orange : (role == 'admin' ? Colors.blue : Colors.white)),
                        underline: Container(), // Quitar línea fea de abajo
                        items: const [
                          DropdownMenuItem(value: 'user', child: Text('Corredor (Mortal)')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin (Staff Evento)')),
                          DropdownMenuItem(value: 'super_admin', child: Text('Super Admin (Dueño)')),
                          DropdownMenuItem(value: 'sudo', child: Text('Sudo (Plataforma)')),
                        ],
                        onChanged: (newRole) {
                          if (newRole != null && newRole != role) {
                            _updateUserRole(context, uid, newRole);
                          }
                        },
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
