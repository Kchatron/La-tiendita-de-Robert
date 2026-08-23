import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/bookshop_provider.dart';
import '../../../data/models/book.dart';
import '../../../data/models/user.dart';

class AuthorScreens extends StatefulWidget {
  final String authorId;
  final String? authorName;

  const AuthorScreens({super.key, required this.authorId, this.authorName});

  @override
  State<AuthorScreens> createState() => _AuthorScreensState();
}

// Alias para mantener compatibilidad con book_detail_screen.dart
class AuthorProfileScreen extends AuthorScreens {
  const AuthorProfileScreen({super.key, required super.authorId, super.authorName});
}

class _AuthorScreensState extends State<AuthorScreens> {
  User? _author;
  List<Book> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<BookShopProvider>(context, listen: false);
    try {
      final authorResult = await provider.bookShopRepository.getUser(widget.authorId);
      final booksResult = await provider.bookShopRepository.getApprovedBooksByAuthor(widget.authorId);

      setState(() {
        _author = authorResult;
        _books = booksResult;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final displayName = _author?.name ?? widget.authorName ?? 'Perfil del Autor';

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 40,
            child: Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : 'A',
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          const Text(
            'Libros Publicados',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_books.isEmpty)
            const Text('No hay libros publicados por este autor.')
          else
            ..._books.map((book) => ListTile(
              title: Text(book.title),
              subtitle: Text('S/ ${book.price}'),
            )),
        ],
      ),
    );
  }
}