import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../local/db_helper.dart';
import '../models/user.dart';
import 'auth_repository.dart';

/// Implementación de autenticación y perfiles basada en Firebase.
class FirebaseAuthRepository extends AuthRepository {
  FirebaseAuthRepository({required super.dbHelper});

  static const _primaryAdminUid = 'NSKN8zAaBpXmvgPPS5fWAZm8XeF2';

  final _auth = firebase_auth.FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User? _firebaseUser;

  @override
  User? get currentUser => _firebaseUser;

  @override
  Future<void> initSession() async {
    final account = _auth.currentUser;
    _firebaseUser = account == null ? null : await _ensureProfile(account);
  }

  @override
  Future<User?> login(String email, String pass) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: pass,
    );
    _firebaseUser = await _ensureProfile(credential.user!);
    return _firebaseUser;
  }

  @override
  Future<User> register(
    String name,
    String email,
    String pass,
    List<String> genres,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: pass,
    );
    await credential.user!.updateDisplayName(name.trim());
    _firebaseUser = await _ensureProfile(
      credential.user!,
      name: name.trim(),
      preferences: genres,
    );
    return _firebaseUser!;
  }

  Future<User> _ensureProfile(
    firebase_auth.User account, {
    String? name,
    List<String>? preferences,
  }) async {
    final reference = _firestore.collection('users').doc(account.uid);
    final snapshot = await reference.get();
    if (snapshot.exists && snapshot.data() != null) {
      return User.fromMap(Map<String, dynamic>.from(snapshot.data()!));
    }

    final profile = User(
      id: account.uid,
      name: name?.isNotEmpty == true
          ? name!
          : (account.displayName?.isNotEmpty == true
              ? account.displayName!
              : (account.email?.split('@').first ?? 'Usuario')),
      email: account.email ?? '',
      photoUrl: account.photoURL ?? '',
      role: account.uid == _primaryAdminUid ? User.ROLE_ADMIN : User.ROLE_USER,
      preferences: preferences ?? const [],
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await reference.set(profile.toMap());
    return profile;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
    _firebaseUser = null;
  }

  @override
  Future<void> switchToDemoUser() async {}

  @override
  Future<void> switchToDemoAdmin() async {}

  @override
  Future<void> updatePreferences(String userId, List<String> genres) async {
    if (_firebaseUser == null || _firebaseUser!.id != userId) return;
    await _firestore.collection('users').doc(userId).update({
      'preferences': genres.join(','),
    });
    _firebaseUser = _firebaseUser!.copyWith(preferences: genres);
  }

  @override
  Future<void> updateProfile(
    String userId,
    String name,
    String bio,
    String photoUrl,
  ) async {
    if (_firebaseUser == null || _firebaseUser!.id != userId) return;
    final updated = _firebaseUser!.copyWith(
      name: name.trim(),
      bio: bio.trim(),
      photoUrl: photoUrl.isEmpty ? _firebaseUser!.photoUrl : photoUrl,
    );
    await _firestore.collection('users').doc(userId).set(updated.toMap());
    _firebaseUser = updated;
  }

  @override
  Future<void> toggleCurrentAdminRole() async {
    // El rol se controla con las reglas de Firestore, no desde un interruptor
    // del cliente. La cuenta principal ya se marca como administradora.
  }
}
