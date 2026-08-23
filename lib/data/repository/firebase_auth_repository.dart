import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  fb.User? get currentUser => _auth.currentUser;
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (userCredential.user != null) {
      final doc = await _db.collection('users').doc(userCredential.user!.uid).get();
      if (doc.exists && doc.data() != null) {
        return User.fromMap(doc.data()!);
      }
    }
    return null;
  }

  @override
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final firebaseUser = userCredential.user;
    if (firebaseUser != null) {
      final appUser = User(
        id: firebaseUser.uid,
        email: email,
        name: name,
        role: role,
        active: true,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _db.collection('users').doc(firebaseUser.uid).set(appUser.toMap());
      return appUser;
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}