import 'dart:async';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../local/db_helper.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../models/transactions_and_stats.dart';
import 'pdf_manager.dart';

class BookShopRepository {
  final DbHelper dbHelper;
  final PdfManager pdfManager;

  BookShopRepository({required this.dbHelper, required this.pdfManager});

  // --- BOOKS ---

  Future<List<Book>> getApprovedBooks() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'status = ?',
      whereArgs: [Book.STATUS_APPROVED],
    );
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<Book?> getBook(String id) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Book.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Book>> getPendingBooks() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'status = ?',
      whereArgs: [Book.STATUS_PENDING],
    );
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Book>> getAllBooks() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Book>> getBooksByAuthor(String authorId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'authorId = ?',
      whereArgs: [authorId],
    );
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Book>> getApprovedBooksByAuthor(String authorId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'authorId = ? AND status = ?',
      whereArgs: [authorId, Book.STATUS_APPROVED],
    );
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Book>> getBooksByCategory(String categoryId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'books',
      where: 'categoryId = ? AND status = ?',
      whereArgs: [categoryId, Book.STATUS_APPROVED],
    );
    return maps.map((m) => Book.fromMap(m)).toList();
  }

  Future<List<Book>> getTopSellingBooks({int limit = 8}) async {
    final books = await getApprovedBooks();
    books.sort((a, b) => b.downloadCount.compareTo(a.downloadCount));
    return books.take(limit).toList();
  }

  Future<List<Book>> getNewlyPublishedBooks({int limit = 8}) async {
    final books = await getApprovedBooks();
    books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return books.take(limit).toList();
  }

  Future<List<Book>> getTopRatedBooks({int limit = 8}) async {
    final books = await getApprovedBooks();
    final ratedBooks = books.where((b) => b.ratingCount > 0).toList();
    ratedBooks.sort((a, b) => b.ratingAverage.compareTo(a.ratingAverage));
    return ratedBooks.take(limit).toList();
  }

  Future<List<Book>> getFreeBooks() async {
    final books = await getApprovedBooks();
    return books.where((b) => b.isFree).toList();
  }

  // --- RECOMMENDATION ALGORITHM ---

  Future<List<Book>> getRecommendedBooks(User? user, {int limit = 8}) async {
    final books = await getApprovedBooks();
    if (user == null) {
      books.sort((a, b) => b.ratingAverage.compareTo(a.ratingAverage));
      return books.take(limit).toList();
    }

    final db = await dbHelper.database;
    // Get favorites
    final List<Map<String, dynamic>> favMaps = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [user.id],
    );
    final favBookIds = favMaps.map((m) => m['bookId'] as String).toSet();

    // Get library
    final List<Map<String, dynamic>> libMaps = await db.query(
      'library',
      where: 'userId = ?',
      whereArgs: [user.id],
    );
    final libraryBookIds = libMaps.map((m) => m['bookId'] as String).toSet();

    final userPrefs = user.preferences.map((p) => p.toLowerCase()).toList();

    // Categories of favorites and library
    final favCategoryIds = books.where((b) => favBookIds.contains(b.id)).map((b) => b.categoryId).toSet();
    final libraryCategoryIds = books.where((b) => libraryBookIds.contains(b.id)).map((b) => b.categoryId).toSet();

    final List<MapEntry<Book, int>> scoredBooks = [];

    for (var book in books) {
      var score = 0;
      final catLower = book.categoryId.toLowerCase();

      // +5 matching genre preference
      if (userPrefs.any((pref) => catLower.contains(pref) || pref.contains(catLower))) {
        score += 5;
      }
      // +3 in category of favorites
      if (favCategoryIds.contains(book.categoryId)) {
        score += 3;
      }
      // +2 in category of library items
      if (libraryCategoryIds.contains(book.categoryId)) {
        score += 2;
      }
      // +1 high rating
      if (book.ratingAverage >= 4.7) {
        score += 1;
      }
      // +1 popular
      if (book.downloadCount > 100) {
        score += 1;
      }

      scoredBooks.add(MapEntry(book, score));
    }

    // Sort by score (descending), then by rating (descending)
    scoredBooks.sort((a, b) {
      final scoreCompare = b.value.compareTo(a.value);
      if (scoreCompare != 0) return scoreCompare;
      return b.key.ratingAverage.compareTo(a.key.ratingAverage);
    });

    return scoredBooks.map((e) => e.key).take(limit).toList();
  }

  Future<void> incrementBookView(String bookId) async {
    final db = await dbHelper.database;
    await db.rawUpdate(
      'UPDATE books SET viewCount = viewCount + 1 WHERE id = ?',
      [bookId],
    );
  }

  // --- CATEGORIES ---

  Future<List<Category>> getActiveCategories() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'active = ?',
      whereArgs: [1],
    );
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<List<Category>> getAllCategories() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  Future<void> createCategory(String id, String name, String iconName, String description) async {
    final db = await dbHelper.database;
    final catId = id.isEmpty ? 'cat_${Random().nextInt(900000) + 100000}' : id;
    final cat = Category(
      id: catId,
      name: name.trim(),
      iconName: iconName.isEmpty ? 'menu_book' : iconName,
      description: description.trim(),
      active: true,
    );
    await db.insert('categories', cat.toMap());
  }

  Future<void> updateCategory(Category category) async {
    final db = await dbHelper.database;
    await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  // --- PUBLISHING & MODERATION ---

  Future<Book> publishBook({
    required String title,
    required String description,
    required String author,
    required String authorId,
    required String categoryId,
    required String coverUrl,
    required String pdfFileName,
    required double fileSizeMb,
    required double price,
    required String language,
    required int publicationYear,
    required String isbn,
    required int pageCount,
  }) async {
    final db = await dbHelper.database;
    final id = 'book_${Random().nextInt(90000000) + 10000000}';
    final book = Book(
      id: id,
      title: title.trim(),
      description: description.trim(),
      author: author.trim(),
      authorId: authorId,
      categoryId: categoryId,
      coverUrl: coverUrl.isEmpty ? 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&q=80' : coverUrl,
      pdfStoragePath: '/books/$id/$pdfFileName',
      pdfFileName: pdfFileName.isEmpty ? 'libro.pdf' : pdfFileName,
      fileSizeMb: fileSizeMb,
      price: price,
      language: language,
      publicationYear: publicationYear,
      isbn: isbn,
      pageCount: pageCount,
      status: Book.STATUS_PENDING,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await db.insert('books', book.toMap());
    return book;
  }

  Future<void> resubmitBook({
    required String bookId,
    required String title,
    required String description,
    required String categoryId,
    required double price,
    required int pageCount,
    required String isbn,
  }) async {
    final db = await dbHelper.database;
    await db.update(
      'books',
      {
        'title': title.trim(),
        'description': description.trim(),
        'categoryId': categoryId,
        'price': price,
        'pageCount': pageCount,
        'isbn': isbn,
        'status': Book.STATUS_PENDING,
        'rejectionReason': null,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  Future<void> updateBookStatus(String bookId, String status) async {
    final db = await dbHelper.database;
    if (status == Book.STATUS_APPROVED) {
      await db.update(
        'books',
        {
          'status': Book.STATUS_APPROVED,
          'rejectionReason': null,
          'approvedAt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [bookId],
      );
    } else if (status == Book.STATUS_REJECTED) {
      await db.update(
        'books',
        {
          'status': Book.STATUS_REJECTED,
          'rejectionReason': 'No cumple con las normas de publicación.',
          'approvedAt': null,
        },
        where: 'id = ?',
        whereArgs: [bookId],
      );
    } else if (status == Book.STATUS_SUSPENDED) {
      await db.update(
        'books',
        {
          'status': Book.STATUS_SUSPENDED,
          'rejectionReason': 'Publicación suspendida por administración',
          'approvedAt': null,
        },
        where: 'id = ?',
        whereArgs: [bookId],
      );
    } else {
      await db.update(
        'books',
        {'status': status},
        where: 'id = ?',
        whereArgs: [bookId],
      );
    }
  }

  Future<void> approveBook(String bookId) async {
    await updateBookStatus(bookId, Book.STATUS_APPROVED);
  }

  Future<void> rejectBook(String bookId, String reason) async {
    final db = await dbHelper.database;
    await db.update(
      'books',
      {
        'status': Book.STATUS_REJECTED,
        'rejectionReason': reason.trim().isEmpty ? 'No cumple con las normas de publicación.' : reason.trim(),
        'approvedAt': null,
      },
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  // --- LIBRARY & PURCHASES ---

  Future<List<MapEntry<LibraryItem, Book>>> getUserLibrary(String userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> libMaps = await db.query(
      'library',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    final List<MapEntry<LibraryItem, Book>> items = [];

    for (var m in libMaps) {
      final libItem = LibraryItem.fromMap(m);
      final book = await getBook(libItem.bookId);
      if (book != null) {
        items.add(MapEntry(libItem, book));
      }
    }
    return items;
  }

  Future<bool> hasAccessToBook(String userId, String bookId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'library',
      where: 'userId = ? AND bookId = ?',
      whereArgs: [userId, bookId],
    );
    return maps.isNotEmpty;
  }

  Future<bool> addFreeBookToLibrary(String userId, Book book) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'library',
      where: 'userId = ? AND bookId = ?',
      whereArgs: [userId, book.id],
    );

    if (maps.isEmpty) {
      final libItem = LibraryItem(
        id: 'lib_${Random().nextInt(900000) + 100000}',
        userId: userId,
        bookId: book.id,
        source: LibraryItem.SOURCE_FREE,
        acquiredAt: DateTime.now().millisecondsSinceEpoch,
      );
      await db.insert('library', libItem.toMap());
      await db.rawUpdate(
        'UPDATE books SET downloadCount = downloadCount + 1 WHERE id = ?',
        [book.id],
      );
    }
    return true;
  }

  Future<Purchase> processPurchase(String userId, Book book, String paymentMethod) async {
    final db = await dbHelper.database;

    final purchase = Purchase(
      id: 'pur_${Random().nextInt(900000) + 100000}',
      userId: userId,
      bookId: book.id,
      bookTitle: book.title,
      bookCover: book.coverUrl,
      price: book.price,
      paymentMethod: paymentMethod,
      paymentStatus: 'completed',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await db.insert('purchases', purchase.toMap());

    // Add to library
    final libItem = LibraryItem(
      id: 'lib_${Random().nextInt(900000) + 100000}',
      userId: userId,
      bookId: book.id,
      source: LibraryItem.SOURCE_PURCHASE,
      acquiredAt: DateTime.now().millisecondsSinceEpoch,
    );
    await db.insert('library', libItem.toMap());

    // Increment download count
    await db.rawUpdate(
      'UPDATE books SET downloadCount = downloadCount + 1 WHERE id = ?',
      [book.id],
    );

    return purchase;
  }

  Future<void> downloadBookPdf(String userId, Book book) async {
    final db = await dbHelper.database;
    final file = await pdfManager.generateSamplePdf(book);

    await db.rawUpdate(
      'UPDATE library SET isDownloaded = 1, downloadedAt = ?, localFilePath = ? WHERE userId = ? AND bookId = ?',
      [DateTime.now().millisecondsSinceEpoch, file.path, userId, book.id],
    );
  }

  // --- FAVORITES ---

  Future<List<Book>> getUserFavoriteBooks(String userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    final List<Book> books = [];
    for (var m in maps) {
      final book = await getBook(m['bookId'] as String);
      if (book != null) {
        books.add(book);
      }
    }
    return books;
  }

  Future<Set<String>> getUserFavoriteBookIds(String userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((m) => m['bookId'] as String).toSet();
  }

  Future<void> toggleFavorite(String userId, String bookId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'userId = ? AND bookId = ?',
      whereArgs: [userId, bookId],
    );

    if (maps.isNotEmpty) {
      await db.delete(
        'favorites',
        where: 'userId = ? AND bookId = ?',
        whereArgs: [userId, bookId],
      );
    } else {
      final fav = FavoriteItem(
        id: 'fav_${Random().nextInt(900000) + 100000}',
        userId: userId,
        bookId: bookId,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await db.insert('favorites', fav.toMap());
    }
  }

  // --- REVIEWS ---

  Stream<List<Review>> getReviewsForBookStream(String bookId) async* {
    final db = await dbHelper.database;
    while (true) {
      final List<Map<String, dynamic>> maps = await db.query(
        'reviews',
        where: 'bookId = ?',
        orderBy: 'createdAt DESC',
      );
      yield maps.map((m) => Review.fromMap(m)).toList();
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<List<Review>> getReviewsForBook(String bookId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'bookId = ?',
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => Review.fromMap(m)).toList();
  }

  Future<void> addOrUpdateReview({
    required String userId,
    required String userName,
    required String userPhoto,
    required String bookId,
    required int rating,
    required String comment,
  }) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'userId = ? AND bookId = ?',
    );

    if (maps.isNotEmpty) {
      final existingId = maps.first['id'] as String;
      await db.update(
        'reviews',
        {
          'rating': rating,
          'comment': comment,
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [existingId],
      );
    } else {
      final review = Review(
        id: 'rev_${Random().nextInt(900000) + 100000}',
        userId: userId,
        userName: userName,
        userPhoto: userPhoto,
        bookId: bookId,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await db.insert('reviews', review.toMap());
    }

    // Update book average rating
    await _updateBookRatingStats(bookId);
  }

  Future<void> deleteReview(String reviewId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'id = ?',
      whereArgs: [reviewId],
    );
    if (maps.isEmpty) return;
    final bookId = maps.first['bookId'] as String;

    await db.delete(
      'reviews',
      where: 'id = ?',
      whereArgs: [reviewId],
    );

    await _updateBookRatingStats(bookId);
  }

  Future<List<Review>> getAllReviews() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('reviews');
    return maps.map((m) => Review.fromMap(m)).toList();
  }

  Future<void> _updateBookRatingStats(String bookId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reviews',
      where: 'bookId = ?',
    );

    if (maps.isEmpty) {
      await db.update(
        'books',
        {
          'ratingAverage': 0.0,
          'ratingCount': 0,
        },
        where: 'id = ?',
        whereArgs: [bookId],
      );
      return;
    }

    final totalRating = maps.map((m) => m['rating'] as int).reduce((a, b) => a + b);
    final count = maps.length;
    final average = totalRating / count;

    await db.update(
      'books',
      {
        'ratingAverage': average,
        'ratingCount': count,
      },
      where: 'id = ?',
      whereArgs: [bookId],
    );
  }

  // --- STATS ---

  Future<AuthorStats> getAuthorStats(String authorId) async {
    final db = await dbHelper.database;
    final books = await getBooksByAuthor(authorId);
    final approved = books.where((b) => b.isApproved).toList();

    var views = 0;
    var downloads = 0;
    var ratingSum = 0.0;
    var ratingCount = 0;
    var salesCount = 0;
    var revenue = 0.0;

    for (var b in books) {
      views += b.viewCount;
      downloads += b.downloadCount;
      if (b.ratingCount > 0) {
        ratingSum += b.ratingAverage * b.ratingCount;
        ratingCount += b.ratingCount;
      }

      // Count purchases of this book
      final List<Map<String, dynamic>> purMaps = await db.query(
        'purchases',
        where: 'bookId = ?',
      );
      salesCount += purMaps.length;
      revenue += purMaps.length * b.price;
    }

    final avgRating = ratingCount > 0 ? ratingSum / ratingCount : 0.0;

    return AuthorStats(
      totalBooks: approved.length,
      totalViews: views,
      totalDownloads: downloads,
      averageRating: avgRating,
      totalSales: salesCount,
      simulatedRevenue: revenue,
    );
  }

  Future<AdminStats> getAdminStats() async {
    final db = await dbHelper.database;

    final usersCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM users')) ?? 0;
    final booksCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM books')) ?? 0;
    final pendingCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM books WHERE status = ?', [Book.STATUS_PENDING])) ?? 0;
    final approvedCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM books WHERE status = ?', [Book.STATUS_APPROVED])) ?? 0;
    final downloadsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT SUM(downloadCount) FROM books')) ?? 0;
    final reviewsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM reviews')) ?? 0;

    // Sum revenue from purchases
    final List<Map<String, dynamic>> revMaps = await db.rawQuery('SELECT SUM(price) as total FROM purchases');
    final revenue = (revMaps.first['total'] as num? ?? 0.0).toDouble();

    return AdminStats(
      totalUsers: usersCount,
      totalBooks: booksCount,
      pendingBooks: pendingCount,
      approvedBooks: approvedCount,
      totalDownloads: downloadsCount,
      simulatedRevenue: revenue,
      totalReviews: reviewsCount,
    );
  }

  Future<List<User>> getAllUsers() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return maps.map((m) => User.fromMap(m)).toList();
  }

  Future<User?> getUser(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return maps.isEmpty ? null : User.fromMap(maps.first);
  }

  Future<void> toggleUserRole(User user) async {
    final db = await dbHelper.database;
    final newRole = user.role == User.ROLE_ADMIN ? User.ROLE_USER : User.ROLE_ADMIN;
    await db.update(
      'users',
      {'role': newRole},
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> toggleUserActive(User user) async {
    final db = await dbHelper.database;
    final newActive = user.active ? 0 : 1;
    await db.update(
      'users',
      {'active': newActive},
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<List<Purchase>> getUserPurchases(String userId) async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'purchases',
      where: 'userId = ?',
      orderBy: 'createdAt DESC',
    );
    return maps.map((m) => Purchase.fromMap(m)).toList();
  }
}
