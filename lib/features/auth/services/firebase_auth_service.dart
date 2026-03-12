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

  Future<User?> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final credential = await _auth.signInWithPopup(googleProvider);
      return credential.user;
    } catch (e) {
      throw Exception('Fallo el acceso con Google: $e');
    }
  }

  Future<User?> signInWithFacebook() async {
    try {
      FacebookAuthProvider facebookProvider = FacebookAuthProvider();
      final credential = await _auth.signInWithPopup(facebookProvider);
      return credential.user;
    } catch (e) {
      throw Exception('Fallo el acceso con Facebook: $e');
    }
  }

  Future<bool> isUserAdmin(String uid) async {
    try {
      final currentUserEmail = _auth.currentUser?.email;
      const List<String> sudoEmails = [
        'emax03736@gmail.com',
        'codemakesoft@gmail.com',
      ];

      if (currentUserEmail != null && sudoEmails.contains(currentUserEmail)) {
        return true; 
      }

      final doc = await _db.collection('users').doc(uid).get();
      if (!doc.exists) return false; 
      
      final String role = doc.data()?['role'] ?? 'user';
      return role == 'admin' || role == 'super_admin' || role == 'sudo'; 
      
    } catch (e) {
      return false; 
    }
  }

  Future<String> getUserRole(User user) async {
    try {
      const List<String> sudoEmails = [
        'emax03736@gmail.com',
        'codemakesoft@gmail.com',
      ];
      if (user.email != null && sudoEmails.contains(user.email)) {
        return 'sudo';
      }

      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return 'user'; 
      
      final String role = doc.data()?['role'] ?? 'user';
      return role; 
      
    } catch (e) {
      return 'user'; 
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
