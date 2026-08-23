import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../models/user.dart';

class BookShopRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Book>> getApprovedBooks() async {
    final snapshot = await _db.collection('books').where('status', isEqualTo: 'approved').get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
  }

  Future<List<Book>> getAllBooks() async {
    final snapshot = await _db.collection('books').get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
  }

  Future<User?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return User.fromMap(doc.data()!);
  }

  Future<List<User>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => User.fromMap(doc.data())).toList();
  }

  Future<List<Category>> getActiveCategories() async {
    final snapshot = await _db.collection('categories').where('active', isEqualTo: 1).get();
    return snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
  }

  Future<List<Book>> getUserFavoriteBooks(String userId) async {
    final snapshot = await _db.collection('users').doc(userId).collection('favorites').get();
    final ids = snapshot.docs.map((doc) => doc.id).toList();
    if (ids.isEmpty) return [];
    final booksSnap = await _db.collection('books').where(FieldPath.documentId, whereIn: ids).get();
    return booksSnap.docs.map((doc) => Book.fromMap(doc.data())).toList();
  }

  Future<void> toggleFavorite(String userId, String bookId) async {
    final ref = _db.collection('users').doc(userId).collection('favorites').doc(bookId);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({'addedAt': DateTime.now().millisecondsSinceEpoch});
    }
  }

  Future<List<Book>> getUserLibrary(String userId) async {
    final snapshot = await _db.collection('users').doc(userId).collection('library').get();
    final ids = snapshot.docs.map((d) => d.id).toList();
    if (ids.isEmpty) return [];
    final booksSnap = await _db.collection('books').where(FieldPath.documentId, whereIn: ids).get();
    return booksSnap.docs.map((doc) => Book.fromMap(doc.data())).toList();
  }

  Future<void> processPurchase(String userId, String bookId, String method) async {
    await _db.collection('users').doc(userId).collection('library').doc(bookId).set({
      'bookId': bookId,
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> addFreeBookToLibrary(String userId, String bookId) async {
    await processPurchase(userId, bookId, 'free');
  }

  Future<void> publishBook(Book book) async {
    await _db.collection('books').doc(book.id).set(book.toMap());
  }

  Future<List<Review>> getReviewsForBook(String bookId) async {
    final snapshot = await _db.collection('books').doc(bookId).collection('reviews').get();
    return snapshot.docs.map((doc) => Review.fromMap(doc.data())).toList();
  }

  Future<bool> hasAccessToBook(String userId, String bookId) async {
    final doc = await _db.collection('users').doc(userId).collection('library').doc(bookId).get();
    return doc.exists;
  }

  Future<void> incrementBookView(String bookId) async {
    await _db.collection('books').doc(bookId).update({'viewCount': FieldValue.increment(1)});
  }

  Future<List<Book>> getApprovedBooksByAuthor(String authorId) async {
    final snapshot = await _db
        .collection('books')
        .where('authorId', isEqualTo: authorId)
        .where('status', isEqualTo: 'approved')
        .get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
  }

  Future<void> addOrUpdateReview(Review review) async {
    await _db.collection('books').doc(review.bookId).collection('reviews').doc(review.id).set(review.toMap());
  }
}