import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/bookshop_provider.dart';
import '../../../data/models/book.dart';
import '../../../data/models/review.dart';
import '../../widgets/rating_bar.dart';
import '../checkout/checkout_screen.dart';
import '../author/author_screens.dart';

class BookDetailScreen extends StatefulWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final _reviewController = TextEditingController();
  int _userRating = 5;
  bool _hasAccess = false;
  List<Review> _reviews = [];
  bool _isLoadingAccess = true;

  @override
  void initState() {
    super.initState();
    _checkAccessAndLoadReviews();
    _incrementView();
  }

  Future<void> _incrementView() async {
    final provider = Provider.of<BookShopProvider>(context, listen: false);
    await provider.bookShopRepository.incrementBookView(widget.bookId);
    provider.refreshAll();
  }

  Future<void> _checkAccessAndLoadReviews() async {
    final provider = Provider.of<BookShopProvider>(context, listen: false);
    final user = provider.currentUser;

    if (user != null) {
      final access = await provider.bookShopRepository.hasAccessToBook(user.id, widget.bookId);
      final list = await provider.bookShopRepository.getReviewsForBook(widget.bookId);
      setState(() {
        _hasAccess = access;
        _reviews = list;
        _isLoadingAccess = false;
      });
    }
  }

  Future<void> _submitReview() async {
    if (_reviewController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor escribe un comentario para tu reseña')),
      );
      return;
    }

    final provider = Provider.of<BookShopProvider>(context, listen: false);
    await provider.submitReview(widget.bookId, _userRating, _reviewController.text);
    _reviewController.clear();
    await _checkAccessAndLoadReviews();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reseña guardada')),
      );
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookShopProvider>(context);
    final book = provider.approvedBooks.firstWhere(
      (b) => b.id == widget.bookId,
      orElse: () => provider.allBooks.firstWhere((b) => b.id == widget.bookId),
    );
    final isFavorite = provider.favoriteBookIds.contains(book.id);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Libro'),
        actions: [
          IconButton(
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            color: isFavorite ? Colors.red : null,
            tooltip: 'Favorito',
            onPressed: () {
              provider.toggleFavorite(book);
            },
          ),
        ],
      ),
      body: _isLoadingAccess
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Book card background
                  Container(
                    color: Colors.indigo[50],
                    padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover
                        Card(
                          elevation: 6,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: 110,
                            height: 160,
                            child: book.coverUrl.isNotEmpty
                                ? Image.network(book.coverUrl, fit: BoxFit.cover)
                                : const Icon(Icons.book, size: 48, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Title, Author, ratings
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => AuthorProfileScreen(authorId: book.authorId, authorName: book.author),
                                )),
                                child: Text(
                                  'Por ${book.author}',
                                  style: TextStyle(color: theme.colorScheme.primary, fontSize: 14, decoration: TextDecoration.underline),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Categoría: ${book.categoryId.replaceAll('cat_', '').toUpperCase()}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  RatingBar(rating: book.ratingAverage, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    book.ratingAverage.toStringAsFixed(1),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    ' (${book.ratingCount} valoraciones)',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Metadata Info chips Row (Pages, Language, Size, Views)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoColumn('PÁGINAS', '${book.pageCount} pág.'),
                        _buildInfoColumn('IDIOMA', book.language),
                        _buildInfoColumn('PESO', '${book.fileSizeMb.toStringAsFixed(1)} MB'),
                        _buildInfoColumn('VISTAS', '${book.viewCount}'),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Sinopsis
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sinopsis',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.description,
                          style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Acquisition Actions Panel
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _hasAccess
                        ? ElevatedButton.icon(
                            onPressed: () {
                              // Navigate back to Library scaffold tab
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ve a la pestaña "Biblioteca" para leer este libro')),
                              );
                            },
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Ya disponible en tu biblioteca'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          )
                        : book.isFree
                            ? ElevatedButton.icon(
                                onPressed: () async {
                                  await provider.acquireFreeBook(book);
                                  await _checkAccessAndLoadReviews();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Añadido a tu biblioteca')),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.download),
                                label: const Text('Descargar Gratis'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              )
                            : ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => CheckoutScreen(book: book),
                                    ),
                                  ).then((_) => _checkAccessAndLoadReviews());
                                },
                                icon: const Icon(Icons.shopping_cart),
                                label: Text('Comprar: S/. ${book.price.toStringAsFixed(2)}'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                  ),
                  const Divider(),

                  // Submit Review Form
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Escribe una Reseña',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Calificación: '),
                            RatingBar(
                              rating: _userRating.toDouble(),
                              size: 24,
                              onRatingChanged: (val) {
                                setState(() {
                                  _userRating = val;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _reviewController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Comparte tu opinión sobre este libro...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _submitReview,
                          child: const Text('Enviar Reseña'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),

                  // Reviews List
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reseñas (${_reviews.length})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        if (_reviews.isEmpty)
                          const Text(
                            'Aún no hay reseñas. ¡Sé el primero en calificar este libro!',
                            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _reviews.length,
                            separatorBuilder: (_, __) => const Divider(height: 20),
                            itemBuilder: (context, index) {
                              final r = _reviews[index];
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: r.userPhoto.isNotEmpty ? NetworkImage(r.userPhoto) : null,
                                        radius: 14,
                                        child: r.userPhoto.isEmpty ? const Icon(Icons.person, size: 14) : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        r.userName,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      const Spacer(),
                                      RatingBar(rating: r.rating.toDouble(), size: 12),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    r.comment,
                                    style: TextStyle(color: Colors.grey[800], fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateTime.fromMillisecondsSinceEpoch(r.createdAt).toString().split(' ').first,
                                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                                  ),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
