import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'db_helper.dart';

/// Migra una única vez los datos de demostración de SQLite a Cloud Firestore.
///
/// La aplicación continúa usando SQLite hasta que se migre el repositorio de
/// datos. Este seeder solamente crea las colecciones iniciales en la nube.
class FirestoreSeeder {
  FirestoreSeeder._();

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const _migrationCollection = '_migrations';
  static const _migrationId = 'sqlite_demo_data_v1';

  static Future<void> seedDataToFirestore() async {
    final migrationRef = _firestore
        .collection(_migrationCollection)
        .doc(_migrationId);

    // Evita duplicar o sobrescribir datos si la carga ya se realizó.
    if ((await migrationRef.get()).exists) {
      debugPrint('La migración inicial hacia Firestore ya fue completada.');
      return;
    }

    // Si el proyecto ya tiene datos creados desde Firebase Console, no se
    // sobrescriben con datos de demostración locales.
    final existingBooks = await _firestore.collection('books').limit(1).get();
    if (existingBooks.docs.isNotEmpty) {
      debugPrint('Firestore ya contiene libros; se omite la carga inicial.');
      return;
    }

    final database = await DbHelper.instance.database;
    final categories = await database.query('categories');
    final books = await database.query('books');
    final batch = _firestore.batch();

    for (final category in categories) {
      final data = Map<String, dynamic>.from(category);
      final id = data['id'] as String;
      batch.set(_firestore.collection('categories').doc(id), data);
    }

    for (final book in books) {
      final data = Map<String, dynamic>.from(book);
      final id = data['id'] as String;
      batch.set(_firestore.collection('books').doc(id), data);
    }

    batch.set(migrationRef, {
      'source': 'sqlite_demo_data',
      'categories': categories.length,
      'books': books.length,
      'completedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
    debugPrint(
      'Migración hacia Firestore completada: '
      '${categories.length} categorías y ${books.length} libros.',
    );
  }
}
