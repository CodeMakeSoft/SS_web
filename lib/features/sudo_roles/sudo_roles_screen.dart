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

    Future<void> _updateDisplayName(BuildContext context, String uid, String newName) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'displayName': newName,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nombre actualizado.'), backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      if (context.mounted) _showError(context, 'Error al cambiar nombre: $e');
    }
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _showEditNameDialog(BuildContext context, String uid, String currentName) {
    TextEditingController controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Editar Nombre del Rider', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nombre Completo',
            labelStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              _updateDisplayName(context, uid, controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

    Future<void> _deleteUser(BuildContext context, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario eliminado de la base de datos.'), backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (context.mounted) _showError(context, 'Error al eliminar: $e');
    }
  }

  void _showDeleteConfirmation(BuildContext context, String uid, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('¿Eliminar Usuario?', style: TextStyle(color: Colors.redAccent)),
        content: Text('¿Estás seguro de que quieres eliminar a $name? Esta acción no se puede deshacer.', 
                    style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _deleteUser(context, uid);
              Navigator.pop(context);
            },
            child: const Text('Eliminar definitivamente'),
          ),
        ],
      ),
    );
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
                  DataColumn(label: Text('Corredor', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
                  DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
                  DataColumn(label: Text('Rol', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent))),
                  DataColumn(label: Text('Acciones', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent))),
                ],
                rows: users.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final role = data['role'] ?? 'user';
                  final email = data['email'] ?? 'Oculto';
                  final displayName = data['displayName'] ?? 'Atleta';
                  final uid = doc.id;

                  return DataRow(cells: [
                    DataCell(
                      InkWell(
                        onTap: () => _showEditNameDialog(context, uid, displayName),
                        child: Row(
                          children: [
                            Text(displayName, style: const TextStyle(color: Colors.white)),
                            const SizedBox(width: 8),
                            const Icon(Icons.edit, size: 14, color: Colors.white24),
                          ],
                        ),
                      ),
                    ),
                    DataCell(Text(email, style: const TextStyle(color: Colors.white70))),
                    DataCell(
                      // El selector rápido para que el Sudo cambie los poderes
                      DropdownButton<String>(
                        value: role,
                        dropdownColor: const Color(0xFF1E293B),
                        style: TextStyle(color: role == 'super_admin' ? Colors.orange : (role == 'admin' ? Colors.blue : Colors.white)),
                        underline: Container(), // Quitar línea fea de abajo
                        items: const [
                          DropdownMenuItem(value: 'trial', child: Text('Prueba')),
                          DropdownMenuItem(value: 'user', child: Text('Corredor')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin')),
                          DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                          DropdownMenuItem(value: 'sudo', child: Text('Sudo')),
                        ],
                        onChanged: (newRole) {
                          if (newRole != null && newRole != role) {
                            _updateUserRole(context, uid, newRole);
                          }
                        },
                      ),
                    ),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                        onPressed: () => _showDeleteConfirmation(context, uid, displayName),
                        tooltip: 'Eliminar Usuario',
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
