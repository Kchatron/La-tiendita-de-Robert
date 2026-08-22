import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/book.dart';
import '../../../data/models/transactions_and_stats.dart';
import '../../../data/models/user.dart';
import '../../../providers/bookshop_provider.dart';
import '../../widgets/book_card.dart';
import '../detail/book_detail_screen.dart';
import '../publishing/publish_book_screen.dart';

class AuthorProfileScreen extends StatefulWidget {
  const AuthorProfileScreen({super.key, required this.authorId, required this.authorName});

  final String authorId;
  final String authorName;

  @override
  State<AuthorProfileScreen> createState() => _AuthorProfileScreenState();
}

class _AuthorProfileScreenState extends State<AuthorProfileScreen> {
  User? _author;
  List<Book> _books = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    final provider = context.read<BookShopProvider>();
    final results = await Future.wait([
      provider.bookShopRepository.getUser(widget.authorId),
      provider.bookShopRepository.getApprovedBooksByAuthor(widget.authorId),
    ]);
    if (!mounted) return;
    setState(() {
      _author = results[0] as User?;
      _books = results[1] as List<Book>;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final downloads = _books.fold<int>(0, (sum, book) => sum + book.downloadCount);
    final rated = _books.where((book) => book.ratingCount > 0).toList();
    final averageRating = rated.isEmpty
        ? 0.0
        : rated.fold<double>(0, (sum, book) => sum + book.ratingAverage) / rated.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil de Autor')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAuthor,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          height: 130,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -48),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 48,
                                  backgroundColor: theme.colorScheme.surface,
                                  backgroundImage: _author?.photoUrl.isNotEmpty == true
                                      ? NetworkImage(_author!.photoUrl)
                                      : null,
                                  child: _author?.photoUrl.isNotEmpty == true
                                      ? null
                                      : Icon(Icons.person, size: 48, color: theme.colorScheme.primary),
                                ),
                                const SizedBox(height: 10),
                                Text(_author?.name ?? widget.authorName,
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Chip(
                                  label: const Text('Autor en BookShop'),
                                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  visualDensity: VisualDensity.compact,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _author?.bio.isNotEmpty == true
                                      ? _author!.bio
                                      : 'Autor y creador de contenidos digitales en BookShop.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(child: _MetricCard(label: 'Libros', value: '${_books.length}', icon: Icons.menu_book)),
                                    const SizedBox(width: 10),
                                    Expanded(child: _MetricCard(label: 'Descargas', value: '$downloads', icon: Icons.download)),
                                    const SizedBox(width: 10),
                                    Expanded(child: _MetricCard(label: 'Valoración', value: '${averageRating.toStringAsFixed(1)} ★', icon: Icons.star)),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Obras Publicadas (${_books.length})',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_books.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text('Este autor no tiene publicaciones aprobadas actualmente.')),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: .58,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => BookCard(
                            book: _books[index],
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => BookDetailScreen(bookId: _books[index].id),
                            )),
                          ),
                          childCount: _books.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class AuthorStatsScreen extends StatelessWidget {
  const AuthorStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<BookShopProvider>().authorStats;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas de Autor')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _RevenueCard(stats: stats),
          const SizedBox(height: 20),
          Text('Métricas de Rendimiento', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _MetricCard(label: 'Libros Publicados', value: '${stats.totalBooks}', icon: Icons.menu_book)),
            const SizedBox(width: 10),
            Expanded(child: _MetricCard(label: 'Visualizaciones', value: '${stats.totalViews}', icon: Icons.visibility)),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _MetricCard(label: 'Descargas Totales', value: '${stats.totalDownloads}', icon: Icons.download)),
            const SizedBox(width: 10),
            Expanded(child: _MetricCard(label: 'Calificación Promedio', value: '${stats.averageRating.toStringAsFixed(1)} ★', icon: Icons.star)),
          ]),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('¿Listo para publicar otra obra?', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Sube tus manuscritos y comparte tu conocimiento con la comunidad BookShop.'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PublishBookScreen())),
                    icon: const Icon(Icons.add),
                    label: const Text('Publicar Nuevo Libro'),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.stats});
  final AuthorStats stats;

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Ingresos Simulados Acumulados', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text('S/. ${stats.simulatedRevenue.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Ventas simuladas: ${stats.totalSales} ejemplares de pago', style: const TextStyle(color: Colors.white70)),
          ]),
        ),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(value, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.labelSmall),
          ]),
        ),
      );
}
