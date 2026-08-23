import 'package:flutter/material.dart';
import '../data/models/book.dart';
import '../data/models/category.dart';
import '../data/models/review.dart';
import '../data/models/user.dart';
import '../data/repository/bookshop_repository.dart';
import '../data/repository/firebase_auth_repository.dart';

class BookShopProvider extends ChangeNotifier {
  final BookShopRepository repository;
  final FirebaseAuthRepository authRepository;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  List<Book> _approvedBooks = [];
  List<Book> get approvedBooks => _approvedBooks;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  List<Book> _userFavoriteBooks = [];
  List<Book> get userFavoriteBooks => _userFavoriteBooks;

  List<Book> _userLibrary = [];
  List<Book> get userLibrary => _userLibrary;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  BookShopProvider({
    required this.repository,
    required this.authRepository,
  }) {
    _init();
  }

  void _init() {
    authRepository.authStateChanges.listen((user) async {
      if (user != null) {
        _currentUser = await repository.getUser(user.uid);
        await refreshAll();
      } else {
        _currentUser = null;
        _userFavoriteBooks = [];
        _userLibrary = [];
        notifyListeners();
      }
    });
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

  Future<void> toggleFavorite(String bookId) async {
    if (_currentUser == null) return;
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
    );

    await repository.publishBook(newBook);
    await refreshAll();
    onSuccess();
  }
}