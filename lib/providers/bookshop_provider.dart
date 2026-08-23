import 'package:flutter/material.dart';
import '../data/models/book.dart';
import '../data/models/category.dart';
import '../data/models/review.dart';
import '../data/models/user.dart';
import '../data/repository/bookshop_repository.dart';
import '../data/repository/firebase_auth_repository.dart';

class AdminStats {
  final int totalUsers;
  final int totalBooks;
  final int pendingBooks;
  final int approvedBooks;
  final int totalDownloads;
  final int totalReviews;
  final double simulatedRevenue;

  AdminStats({
    this.totalUsers = 0,
    this.totalBooks = 0,
    this.pendingBooks = 0,
    this.approvedBooks = 0,
    this.totalDownloads = 0,
    this.totalReviews = 0,
    this.simulatedRevenue = 0.0,
  });
}

class BookShopProvider extends ChangeNotifier {
  final BookShopRepository repository;
  final FirebaseAuthRepository authRepository;

  BookShopRepository get bookShopRepository => repository;

  User? _currentUser;
  User? get currentUser => _currentUser;

  List<Book> _approvedBooks = [];
  List<Book> get approvedBooks => _approvedBooks;
  List<Book> get allBooks => _approvedBooks;

  List<Book> _pendingBooks = [];
  List<Book> get pendingBooks => _pendingBooks;

  List<User> _allUsers = [];
  List<User> get allUsers => _allUsers;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  List<Book> _userFavoriteBooks = [];
  List<Book> get userFavoriteBooks => _userFavoriteBooks;
  List<Book> get favoriteBooks => _userFavoriteBooks;
  List<String> get favoriteBookIds => _userFavoriteBooks.map((b) => b.id).toList();

  List<Book> _userLibrary = [];
  List<Book> get userLibrary => _userLibrary;
  List<Book> get myLibraryItems => _userLibrary;

  Map<String, double> downloadingBookIds = {};
  dynamic authorStats;
  List<dynamic> myPublications = [];
  List<dynamic> myPurchases = [];

  AdminStats adminStats = AdminStats();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Book> get topSellingBooks => _approvedBooks;
  List<Book> get newlyPublishedBooks => _approvedBooks;
  List<Book> get topRatedBooks => _approvedBooks;
  List<Book> get freeBooks => _approvedBooks.where((b) => b.price == 0).toList();
  List<Book> get featuredBooks => _approvedBooks.take(5).toList();
  List<Book> get recommendedBooks => _approvedBooks;

  BookShopProvider({
    required this.repository,
    required this.authRepository,
  }) {
    _init();
  }

  void _init() {
    authRepository.authStateChanges.listen((fbUser) async {
      if (fbUser != null) {
        _currentUser = await repository.getUser(fbUser.uid);
        await refreshAll();
      } else {
        _currentUser = null;
        _userFavoriteBooks = [];
        _userLibrary = [];
        notifyListeners();
      }
    });
  }

  Future<void> login(String email, String password) async {
    _currentUser = await authRepository.signInWithEmail(email, password);
    await refreshAll();
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _currentUser = await authRepository.registerWithEmail(
      email: email,
      password: password,
      name: name,
      role: role,
    );
    await refreshAll();
  }

  Future<void> logout() async {
    await authRepository.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      _approvedBooks = await repository.getApprovedBooks();
      _categories = await repository.getActiveCategories();

      if (_currentUser != null) {
        _userFavoriteBooks = await repository.getUserFavoriteBooks(_currentUser!.id);
        _userLibrary = await repository.getUserLibrary(_currentUser!.id);

        if (_currentUser!.isAdmin) {
          _allUsers = await repository.getAllUsers();
          adminStats = AdminStats(
            totalUsers: _allUsers.length,
            totalBooks: _approvedBooks.length,
            approvedBooks: _approvedBooks.length,
          );
        }
      }
    } catch (e) {
      debugPrint("Error al refrescar datos: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String bookId) {
    return _userFavoriteBooks.any((b) => b.id == bookId);
  }

  Future<void> toggleFavorite(dynamic bookOrId) async {
    if (_currentUser == null) return;
    final String bookId = bookOrId is Book ? bookOrId.id : bookOrId.toString();
    await repository.toggleFavorite(_currentUser!.id, bookId);
    _userFavoriteBooks = await repository.getUserFavoriteBooks(_currentUser!.id);
    notifyListeners();
  }

  Future<void> purchaseBook(
      Book book,
      String paymentMethod, {
        required Function(dynamic) onSuccess,
      }) async {
    if (_currentUser == null) return;
    await repository.processPurchase(_currentUser!.id, book.id, paymentMethod);
    await refreshAll();
    onSuccess(null);
  }

  Future<void> acquireFreeBook(Book book) async {
    if (_currentUser == null) return;
    await repository.addFreeBookToLibrary(_currentUser!.id, book.id);
    await refreshAll();
  }

  Future<void> downloadBookPdf(Book book) async {}

  Future<void> submitReview(String bookId, int rating, String comment) async {
    if (_currentUser == null) return;
    final review = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: bookId,
      userId: _currentUser!.id,
      userName: _currentUser!.name,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    await repository.addOrUpdateReview(review);
    notifyListeners();
  }

  Future<void> publishBook({
    required String title,
    required String description,
    required String categoryId,
    required String coverUrl,
    required String pdfFileName,
    required double fileSizeMb,
    required double price,
    required String language,
    required int publicationYear,
    required String isbn,
    required int pageCount,
    required VoidCallback onSuccess,
  }) async {
    if (_currentUser == null) return;

    final newBook = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      author: _currentUser!.name,
      authorId: _currentUser!.id,
      categoryId: categoryId,
      coverUrl: coverUrl,
      pdfFileName: pdfFileName,
      fileSizeMb: fileSizeMb,
      price: price,
      language: language,
      publicationYear: publicationYear,
      isbn: isbn,
      pageCount: pageCount,
      status: 'pending',
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await repository.publishBook(newBook);
    await refreshAll();
    onSuccess();
  }

  Future<void> editBook({
    required String bookId,
    required String title,
    required String description,
    String? categoryId,
    double? price,
    int? pageCount,
    String? isbn,
    VoidCallback? onSuccess,
  }) async {
    await refreshAll();
    if (onSuccess != null){
      onSuccess();
    }
  }

  Future<void> updateUserPreferences(List<String> prefs) async {}

  // --- MÉTODOS DE ADMINISTRACIÓN ---
  Future<void> addCategory(String id, String name, String icon, String description) async {
    final cat = Category(
      id: id,
      name: name,
      description: description,
      active: true,
    );
    _categories.add(cat);
    notifyListeners();
  }

  Future<void> rejectBook(String bookId, String reason) async {
    _pendingBooks.removeWhere((b) => b.id == bookId);
    notifyListeners();
  }

  Future<void> approveBook(String bookId) async {
    _pendingBooks.removeWhere((b) => b.id == bookId);
    await refreshAll();
  }

  Future<void> toggleUserRole(User user) async {}
  Future<void> toggleUserActive(User user) async {}
}