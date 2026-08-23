import 'package:flutter/foundation.dart' hide Category;
import '../data/models/user.dart';
import '../data/models/book.dart';
import '../data/models/category.dart';
import '../data/models/review.dart';
import '../data/models/transactions_and_stats.dart';
import '../data/repository/auth_repository.dart';
import '../data/repository/bookshop_repository.dart';

class BookShopProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final BookShopRepository bookShopRepository;

  BookShopProvider({
    required this.authRepository,
    required this.bookShopRepository,
  }) {
    _init();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // States
  User? _currentUser;
  User? get currentUser => _currentUser;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  List<Book> _approvedBooks = [];
  List<Book> get approvedBooks => _approvedBooks;

  List<Book> _recommendedBooks = [];
  List<Book> get recommendedBooks => _recommendedBooks;

  List<Book> _topSellingBooks = [];
  List<Book> get topSellingBooks => _topSellingBooks;

  List<Book> _newlyPublishedBooks = [];
  List<Book> get newlyPublishedBooks => _newlyPublishedBooks;

  List<Book> _topRatedBooks = [];
  List<Book> get topRatedBooks => _topRatedBooks;

  List<Book> _freeBooks = [];
  List<Book> get freeBooks => _freeBooks;

  Set<String> _favoriteBookIds = {};
  Set<String> get favoriteBookIds => _favoriteBookIds;

  List<Book> _favoriteBooks = [];
  List<Book> get favoriteBooks => _favoriteBooks;

  List<MapEntry<LibraryItem, Book>> _myLibraryItems = [];
  List<MapEntry<LibraryItem, Book>> get myLibraryItems => _myLibraryItems;

  List<Book> _myPublications = [];
  List<Book> get myPublications => _myPublications;

  List<Purchase> _myPurchases = [];
  List<Purchase> get myPurchases => _myPurchases;

  AuthorStats _authorStats = AuthorStats();
  AuthorStats get authorStats => _authorStats;

  AdminStats _adminStats = AdminStats();
  AdminStats get adminStats => _adminStats;

  List<Book> _pendingBooks = [];
  List<Book> get pendingBooks => _pendingBooks;

  List<Book> _allBooks = [];
  List<Book> get allBooks => _allBooks;

  List<User> _allUsers = [];
  List<User> get allUsers => _allUsers;

  List<Review> _allReviews = [];
  List<Review> get allReviews => _allReviews;

  // Downloading Progress
  final Map<String, double> _downloadingBookIds = {};
  Map<String, double> get downloadingBookIds => _downloadingBookIds;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    await authRepository.initSession();
    _currentUser = authRepository.currentUser;

    await refreshAll();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshAll() async {
    _currentUser = authRepository.currentUser;

    // Load Parallel Stats & Lists
    _categories = await bookShopRepository.getAllCategories();
    _approvedBooks = await bookShopRepository.getApprovedBooks();
    _topSellingBooks = await bookShopRepository.getTopSellingBooks();
    _newlyPublishedBooks = await bookShopRepository.getNewlyPublishedBooks();
    _topRatedBooks = await bookShopRepository.getTopRatedBooks();
    _freeBooks = await bookShopRepository.getFreeBooks();

    if (_currentUser != null) {
      final uid = _currentUser!.id;
      _recommendedBooks = await bookShopRepository.getRecommendedBooks(_currentUser);
      _favoriteBookIds = await bookShopRepository.getUserFavoriteBookIds(uid);
      _favoriteBooks = await bookShopRepository.getUserFavoriteBooks(uid);
      _myLibraryItems = await bookShopRepository.getUserLibrary(uid);
      _myPublications = await bookShopRepository.getBooksByAuthor(uid);
      _myPurchases = await bookShopRepository.getUserPurchases(uid);
      _authorStats = await bookShopRepository.getAuthorStats(uid);
    } else {
      _recommendedBooks = [];
      _favoriteBookIds = {};
      _favoriteBooks = [];
      _myLibraryItems = [];
      _myPublications = [];
      _myPurchases = [];
      _authorStats = AuthorStats();
    }

    if (_currentUser != null && _currentUser!.isAdmin) {
      _adminStats = await bookShopRepository.getAdminStats();
      _pendingBooks = await bookShopRepository.getPendingBooks();
      _allBooks = await bookShopRepository.getAllBooks();
      _allUsers = await bookShopRepository.getAllUsers();
      _allReviews = await bookShopRepository.getAllReviews();
    } else {
      _adminStats = AdminStats();
      _pendingBooks = [];
      _allBooks = [];
      _allUsers = [];
      _allReviews = [];
    }

    notifyListeners();
  }

  // --- ACTIONS ---

  Future<void> login(String email, String pass) async {
    _isLoading = true;
    notifyListeners();
    try {
      await authRepository.login(email, pass);
      await refreshAll();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String pass, List<String> genres) async {
    _isLoading = true;
    notifyListeners();
    try {
      await authRepository.register(name, email, pass, genres);
      await refreshAll();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    await refreshAll();
  }

  Future<void> switchToDemoUser() async {
    await authRepository.switchToDemoUser();
    await refreshAll();
  }

  Future<void> switchToDemoAdmin() async {
    await authRepository.switchToDemoAdmin();
    await refreshAll();
  }

  Future<void> toggleAdminRole() async {
    await authRepository.toggleCurrentAdminRole();
    await refreshAll();
  }

  Future<void> toggleFavorite(Book book) async {
    if (_currentUser == null) return;
    await bookShopRepository.toggleFavorite(_currentUser!.id, book.id);
    await refreshAll();
  }

  Future<void> acquireFreeBook(Book book) async {
    if (_currentUser == null) return;
    await bookShopRepository.addFreeBookToLibrary(_currentUser!.id, book);
    await refreshAll();
  }

  Future<void> purchaseBook(Book book, String paymentMethod, {required Function(Purchase) onSuccess}) async {
    if (_currentUser == null) return;
    final purchase = await bookShopRepository.processPurchase(_currentUser!.id, book, paymentMethod);
    await refreshAll();
    onSuccess(purchase);
  }

  Future<void> downloadBookPdf(Book book) async {
    if (_currentUser == null) return;
    final uid = _currentUser!.id;

    // Simulate progress download
    _downloadingBookIds[book.id] = 0.15;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    _downloadingBookIds[book.id] = 0.50;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));

    _downloadingBookIds[book.id] = 0.85;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));

    _downloadingBookIds[book.id] = 1.0;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 200));

    await bookShopRepository.downloadBookPdf(uid, book);
    _downloadingBookIds.remove(book.id);
    await refreshAll();
  }

  Future<void> submitReview(String bookId, int rating, String comment) async {
    if (_currentUser == null) return;
    await bookShopRepository.addOrUpdateReview(
      userId: _currentUser!.id,
      userName: _currentUser!.name,
      userPhoto: _currentUser!.photoUrl,
      bookId: bookId,
      rating: rating,
      comment: comment,
    );
    await refreshAll();
  }

  Future<void> deleteReview(String reviewId) async {
    await bookShopRepository.deleteReview(reviewId);
    await refreshAll();
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
    await bookShopRepository.publishBook(
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
    );
    await refreshAll();
    onSuccess();
  }

  Future<void> editBook({
    required String bookId,
    required String title,
    required String description,
    required String categoryId,
    required double price,
    required int pageCount,
    required String isbn,
    required VoidCallback onSuccess,
  }) async {
    await bookShopRepository.resubmitBook(
      bookId: bookId,
      title: title,
      description: description,
      categoryId: categoryId,
      price: price,
      pageCount: pageCount,
      isbn: isbn,
    );
    await refreshAll();
    onSuccess();
  }

  // Admin Actions
  Future<void> approveBook(String bookId) async {
    await bookShopRepository.approveBook(bookId);
    await refreshAll();
  }

  Future<void> rejectBook(String bookId, String reason) async {
    await bookShopRepository.rejectBook(bookId, reason);
    await refreshAll();
  }

  Future<void> updateBookStatus(String bookId, String status) async {
    await bookShopRepository.updateBookStatus(bookId, status);
    await refreshAll();
  }

  Future<void> toggleUserRole(User user) async {
    await bookShopRepository.toggleUserRole(user);
    await refreshAll();
  }

  Future<void> toggleUserActive(User user) async {
    await bookShopRepository.toggleUserActive(user);
    await refreshAll();
  }

  Future<void> addCategory(String id, String name, String iconName, String description) async {
    await bookShopRepository.createCategory(id, name, iconName, description);
    await refreshAll();
  }

  Future<void> updateUserPreferences(List<String> genres) async {
    if (_currentUser == null) return;
    await authRepository.updatePreferences(_currentUser!.id, genres);
    await refreshAll();
  }

  Future<void> updateUserProfile(String name, String bio, String photoUrl) async {
    if (_currentUser == null) return;
    await authRepository.updateProfile(_currentUser!.id, name, bio, photoUrl);
    await refreshAll();
  }
}
