import '../models/user.dart';

abstract class AuthRepository {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  });
  Future<void> signOut();
}