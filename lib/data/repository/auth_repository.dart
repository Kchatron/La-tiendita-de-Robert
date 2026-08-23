import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirebaseAuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<AppUser?> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user != null) {
      final doc = await _db.collection('users').doc(userCredential.user!.uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!);
      }
    }
    return null;
  }

  Future<AppUser?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;
    if (user != null) {
      final appUser = AppUser(
        id: user.uid,
        email: email,
        name: name,
        role: role,
        active: 1,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _db.collection('users').doc(user.uid).set(appUser.toMap());
      return appUser;
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}