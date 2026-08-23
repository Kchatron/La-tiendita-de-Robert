import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/bookshop_provider.dart';
import '../../../data/models/book.dart';
import 'pdf_reader_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookShopProvider>(context);
    final libraryBooks = provider.myLibraryItems;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Biblioteca', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: libraryBooks.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Tu biblioteca está vacía',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adquiere libros gratuitos o realiza compras en el catálogo para empezar a leer.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: libraryBooks.length,
        separatorBuilder: (_, __) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final book = libraryBooks[index];

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Portada del libro
              Container(
                width: 75,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: book.coverUrl.isNotEmpty
                    ? Image.network(
                  book.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.book, size: 30, color: Colors.grey),
                )
                    : const Icon(Icons.book, size: 30, color: Colors.grey),
              ),
              const SizedBox(width: 16),

              // Detalles y Botón de lectura directa
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Autor: ${book.author}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PdfReaderScreen(book: book),
                          ),
                        );
                      },
                      icon: const Icon(Icons.chrome_reader_mode, size: 16),
                      label: const Text('Leer Libro'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}