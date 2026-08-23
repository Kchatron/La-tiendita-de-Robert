import '../models/user.dart';

abstract class AuthRepository {
  Future<AppUser?> signInWithEmail(String email, String password);
  Future<AppUser?> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
  });
  Future<void> signOut();
}