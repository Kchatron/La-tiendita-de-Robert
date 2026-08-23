import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../models/user.dart';

class BookShopRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- CATALOGO Y LIBROS ---
  Future<List<Book>> getApprovedBooks() async {
    final snapshot = await _db
        .collection('books')
        .where('status', isEqualTo: 'approved')
        .get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
  }

  Future<List<Book>> getAllBooks() async {
    final snapshot = await _db.collection('books').get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
  }

  Future<List<Book>> getPendingBooks() async {
    final snapshot = await _db
        .collection('books')
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
  }

  Future<List<Book>> getTopSellingBooks() async => getApprovedBooks();
  Future<List<Book>> getNewlyPublishedBooks() async => getApprovedBooks();
  Future<List<Book>> getTopRatedBooks() async => getApprovedBooks();
  Future<List<Book>> getFreeBooks() async {
    final snapshot = await _db
        .collection('books')
        .where('status', isEqualTo: 'approved')
        .where('price', isEqualTo: 0)
        .get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
  }

  Future<List<Book>> getRecommendedBooks(List<String> prefs) async => getApprovedBooks();
  Future<List<Book>> getBooksByAuthor(String authorId) async {
    final snapshot = await _db
        .collection('books')
        .where('authorId', isEqualTo: authorId)
        .get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
  }

  Future<List<Book>> getApprovedBooksByAuthor(String authorId) async {
    final snapshot = await _db
        .collection('books')
        .where('authorId', isEqualTo: authorId)
        .where('status', isEqualTo: 'approved')
        .get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
  }

  Future<void> publishBook(Book book) async {
    await _db.collection('books').doc(book.id).set(book.toMap());
  }

  Future<void> resubmitBook(Book book) async {
    final data = book.toMap();
    data['status'] = 'pending';
    await _db.collection('books').doc(book.id).update(data);
  }

  Future<void> approveBook(String bookId) async {
    await _db.collection('books').doc(bookId).update({
      'status': 'approved',
      'approvedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> rejectBook(String bookId, String reason) async {
    await _db.collection('books').doc(bookId).update({
      'status': 'rejected',
      'rejectionReason': reason,
    });
  }

  Future<void> incrementBookView(String bookId) async {
    await _db.collection('books').doc(bookId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  // --- CATEGORIAS ---
  Future<List<Category>> getActiveCategories() async {
    final snapshot = await _db
        .collection('categories')
        .where('active', isEqualTo: 1)
        .get();
    return snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
  }

  Future<List<Category>> getAllCategories() async {
    final snapshot = await _db.collection('categories').get();
    return snapshot.docs.map((doc) => Category.fromMap(doc.data())).toList();
  }

  Future<void> createCategory(Category category) async {
    await _db.collection('categories').doc(category.id).set(category.toMap());
  }

  // --- USUARIOS Y PERFILES ---
  Future<AppUser?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(doc.data()!);
  }

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList();
  }

  Future<void> toggleUserRole(String userId, String currentRole) async {
    final newRole = currentRole == 'admin' ? 'user' : 'admin';
    await _db.collection('users').doc(userId).update({'role': newRole});
  }

  Future<void> toggleUserActive(String userId, bool currentActive) async {
    await _db.collection('users').doc(userId).update({'active': !currentActive ? 1 : 0});
  }

  // --- FAVORITOS Y BIBLIOTECA ---
  Future<List<String>> getUserFavoriteBookIds(String userId) async {
    final snapshot = await _db.collection('users').doc(userId).collection('favorites').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<Book>> getUserFavoriteBooks(String userId) async {
    final ids = await getUserFavoriteBookIds(userId);
    if (ids.isEmpty) return [];
    final snapshot = await _db.collection('books').where(FieldPath.documentId, whereIn: ids).get();
    return snapshot.docs.map((doc) => Book.fromMap(doc.data())).toList();
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

  Future<bool> hasAccessToBook(String userId, String bookId) async {
    final doc = await _db.collection('users').doc(userId).collection('library').doc(bookId).get();
    return doc.exists;
  }

  Future<void> addBookToLibrary(String userId, String bookId) async {
    await _db.collection('users').doc(userId).collection('library').doc(bookId).set({
      'bookId': bookId,
      'addedAt': DateTime.now().millisecondsSinceEpoch,
    });
    await _db.collection('books').doc(bookId).update({'downloadCount': FieldValue.increment(1)});
  }

  Future<void> addFreeBookToLibrary(String userId, String bookId) async => addBookToLibrary(userId, bookId);

  Future<void> processPurchase(String userId, String bookId, String method) async {
    await addBookToLibrary(userId, bookId);
    await _db.collection('users').doc(userId).collection('purchases').add({
      'bookId': bookId,
      'paymentMethod': method,
      'purchasedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<dynamic>> getUserPurchases(String userId) async => [];
  Future<dynamic> getAuthorStats(String authorId) async => null;
  Future<dynamic> getAdminStats() async => null;

  // --- RESEÑAS ---
  Future<List<Review>> getBookReviews(String bookId) async {
    final snapshot = await _db.collection('books').doc(bookId).collection('reviews').get();
    return snapshot.docs.map((doc) => Review.fromMap(doc.data())).toList();
  }

  Future<List<Review>> getReviewsForBook(String bookId) async => getBookReviews(bookId);
  Future<List<Review>> getAllReviews() async => [];

  Future<void> addReview(Review review) async {
    await _db.collection('books').doc(review.bookId).collection('reviews').doc(review.id).set(review.toMap());
  }

  Future<void> addOrUpdateReview(Review review) async => addReview(review);
  Future<void> deleteReview(String bookId, String reviewId) async {
    await _db.collection('books').doc(bookId).collection('reviews').doc(reviewId).delete();
  }

  Future<void> downloadBookPdf(String bookId) async {}
}