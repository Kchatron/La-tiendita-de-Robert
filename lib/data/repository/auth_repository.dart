import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../local/db_helper.dart';
import '../models/user.dart';

class AuthRepository {
  final DbHelper dbHelper;
  User? _currentUser;

  AuthRepository({required this.dbHelper});

  User? get currentUser => _currentUser;

  // Sign in standard demo user on startup
  Future<void> initSession() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['user@bookshop.demo'],
    );
    if (maps.isNotEmpty) {
      _currentUser = User.fromMap(maps.first);
    }
  }

  Future<User?> login(String email, String pass) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );

    if (maps.isNotEmpty) {
      final user = User.fromMap(maps.first);
      if (!user.active) {
        throw Exception("Esta cuenta ha sido desactivada temporalmente por el administrador.");
      }
      _currentUser = user;
      return user;
    } else {
      // Auto create new user if signing in with custom email
      final randId = 'user_${Random().nextInt(90000000) + 10000000}';
      final newUser = User(
        id: randId,
        name: email.split('@').first,
        email: email.trim().toLowerCase(),
        photoUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80",
        bio: "Lector en BookShop",
        role: email.contains("admin") ? User.ROLE_ADMIN : User.ROLE_USER,
        preferences: ["Programación", "Tecnología"],
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      await db.insert('users', newUser.toMap());
      _currentUser = newUser;
      return newUser;
    }
  }

  Future<User> register(String name, String email, String pass, List<String> genres) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );

    if (maps.isNotEmpty) {
      throw Exception("Ya existe una cuenta con este correo electrónico.");
    }

    final randId = 'user_${Random().nextInt(90000000) + 10000000}';
    final newUser = User(
      id: randId,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      photoUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&q=80",
      bio: "Lector en BookShop",
      role: User.ROLE_USER,
      preferences: genres,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await db.insert('users', newUser.toMap());
    _currentUser = newUser;
    return newUser;
  }

  void logout() {
    _currentUser = null;
  }

  Future<void> switchToDemoUser() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['user@bookshop.demo'],
    );
    if (maps.isNotEmpty) {
      _currentUser = User.fromMap(maps.first);
    }
  }

  Future<void> switchToDemoAdmin() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['admin@bookshop.demo'],
    );
    if (maps.isNotEmpty) {
      _currentUser = User.fromMap(maps.first);
    }
  }

  Future<void> updatePreferences(String userId, List<String> genres) async {
    if (_currentUser == null) return;
    final db = await dbHelper.database;
    final updated = _currentUser!.copyWith(preferences: genres);
    await db.update(
      'users',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [userId],
    );
    _currentUser = updated;
  }

  Future<void> updateProfile(String userId, String name, String bio, String photoUrl) async {
    if (_currentUser == null) return;
    final db = await dbHelper.database;
    final updated = _currentUser!.copyWith(
      name: name,
      bio: bio,
      photoUrl: photoUrl.isEmpty ? _currentUser!.photoUrl : photoUrl,
    );
    await db.update(
      'users',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [userId],
    );
    _currentUser = updated;
  }

  Future<void> toggleCurrentAdminRole() async {
    if (_currentUser == null) return;
    final db = await dbHelper.database;
    final newRole = _currentUser!.role == User.ROLE_ADMIN ? User.ROLE_USER : User.ROLE_ADMIN;
    final updated = _currentUser!.copyWith(role: newRole);
    await db.update(
      'users',
      {'role': newRole},
      where: 'id = ?',
      whereArgs: [_currentUser!.id],
    );
    _currentUser = updated;
  }
}
