import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/bookshop_provider.dart';
import '../../../data/models/book.dart';
import '../../widgets/status_badge.dart';
import 'publish_book_screen.dart';
import 'edit_book_screen.dart';

class MyPublicationsScreen extends StatelessWidget {
  const MyPublicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookShopProvider>(context);
    final stats = provider.authorStats;
    final publications = provider.myPublications;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Autor'),
      ),
      body: Column(
        children: [
          // Stats Row
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.amber[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Publicados', '${stats.totalBooks}'),
                _buildStatItem('Vistas', '${stats.totalViews}'),
                _buildStatItem('Descargas', '${stats.totalDownloads}'),
                _buildStatItem('Calificación', stats.averageRating.toStringAsFixed(1)),
                _buildStatItem('Ganancia', 'S/. ${stats.simulatedRevenue.toStringAsFixed(2)}'),
              ],
            ),
          ),

          // Publications list header
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Mis Libros Publicados',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Publications List
          Expanded(
            child: publications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.menu_book, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No has publicado ningún libro aún',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('¡Toca el botón + para subir tu primera obra!'),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: publications.length,
                    separatorBuilder: (_, __) => const Divider(height: 20),
                    itemBuilder: (context, index) {
                      final book = publications[index];

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Cover
                          Container(
                            width: 50,
                            height: 75,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: book.coverUrl.isNotEmpty
                                ? Image.network(book.coverUrl, fit: BoxFit.cover)
                                : const Icon(Icons.book),
                          ),
                          const SizedBox(width: 16),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  book.isFree ? 'Gratis' : 'S/. ${book.price.toStringAsFixed(2)}',
                                  style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    StatusBadge(status: book.status),
                                    const SizedBox(width: 8),
                                    if (book.rejectionReason != null)
                                      Expanded(
                                        child: Text(
                                          'Motivo: ${book.rejectionReason}',
                                          style: const TextStyle(fontSize: 11, color: Colors.red),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Action
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EditBookScreen(book: book),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PublishBookScreen()),
          );
        },
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.white,
        tooltip: 'Publicar Nuevo Libro',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.indigo)),
      ],
    );
  }
}
