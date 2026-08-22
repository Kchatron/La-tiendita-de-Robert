import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/bookshop_provider.dart';
import '../../../data/models/book.dart';
import '../../widgets/book_card.dart';
import '../detail/book_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildSectionList({
    required BuildContext context,
    required String title,
    required List<Book> books,
  }) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.1,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16.0, right: 8.0),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                book: book,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BookDetailScreen(bookId: book.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookShopProvider>(context);
    final theme = Theme.of(context);
    final currentUser = provider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (currentUser != null && currentUser.photoUrl.isNotEmpty)
              CircleAvatar(
                backgroundImage: NetworkImage(currentUser.photoUrl),
                radius: 18,
              )
            else
              const CircleAvatar(
                backgroundColor: Colors.indigo,
                radius: 18,
                child: Icon(Icons.person, size: 18, color: Colors.white),
              ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hola, ${currentUser?.name ?? "Lector"} 👋',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  currentUser?.role == 'admin' ? 'Administrador' : 'Lector',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
              provider.logout();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.refreshAll,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            // Promotional Banner
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo[900]!, Colors.indigo[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '¡Lectura Ilimitada!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explora miles de títulos en nuestra biblioteca digital. Encuentra libros de programación, finanzas, ciencia ficción y más.',
                    style: TextStyle(
                      color: Colors.indigo[100],
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal sections
            _buildSectionList(
              context: context,
              title: 'Recomendados para ti',
              books: provider.recommendedBooks,
            ),
            _buildSectionList(
              context: context,
              title: 'Más populares',
              books: provider.topSellingBooks,
            ),
            _buildSectionList(
              context: context,
              title: 'Novedades',
              books: provider.newlyPublishedBooks,
            ),
            _buildSectionList(
              context: context,
              title: 'Mejor valorados',
              books: provider.topRatedBooks,
            ),
            _buildSectionList(
              context: context,
              title: 'Acceso gratuito',
              books: provider.freeBooks,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
