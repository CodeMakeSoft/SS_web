import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return credential.user;
    } catch (e) {
      throw Exception('Fallo el acceso: Revisar credenciales de Administrator.');
    }
  }

  Future<bool> isUserAdmin(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return false; 
      
      final String role = doc.data()?['role'] ?? 'user';
      return role == 'admin' || role == 'super_admin'; 
    } catch (e) {
      return false; 
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
