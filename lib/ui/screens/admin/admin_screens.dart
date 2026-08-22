import 'package:flutter/material.dart' hide Category;
import 'package:provider/provider.dart';
import '../../../providers/bookshop_provider.dart';
import '../../../data/models/book.dart';
import '../../../data/models/user.dart';
import '../../../data/models/category.dart';

class AdminScreens extends StatefulWidget {
  const AdminScreens({super.key});

  @override
  State<AdminScreens> createState() => _AdminScreensState();
}

class _AdminScreensState extends State<AdminScreens> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _catIdController = TextEditingController();
  final _catNameController = TextEditingController();
  final _catIconController = TextEditingController(text: 'code');
  final _catDescController = TextEditingController();
  final _rejectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _catIdController.dispose();
    _catNameController.dispose();
    _catIconController.dispose();
    _catDescController.dispose();
    _rejectController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    _catIdController.clear();
    _catNameController.clear();
    _catIconController.text = 'code';
    _catDescController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva Categoría'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _catIdController,
                  decoration: const InputDecoration(labelText: 'ID único (ej. cat_gaming)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _catNameController,
                  decoration: const InputDecoration(labelText: 'Nombre de Categoría'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _catIconController,
                  decoration: const InputDecoration(labelText: 'Icono Material (code, palette...)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _catDescController,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descripción corta'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_catNameController.text.trim().isEmpty) return;
                final provider = Provider.of<BookShopProvider>(context, listen: false);
                provider.addCategory(
                  _catIdController.text,
                  _catNameController.text,
                  _catIconController.text,
                  _catDescController.text,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Categoría creada')),
                );
              },
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );
  }

  void _showRejectDialog(String bookId) {
    _rejectController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rechazar Publicación'),
          content: TextField(
            controller: _rejectController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Motivo del rechazo',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                if (_rejectController.text.trim().isEmpty) return;
                final provider = Provider.of<BookShopProvider>(context, listen: false);
                provider.rejectBook(bookId, _rejectController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Libro rechazado')),
                );
              },
              child: const Text('Rechazar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookShopProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.analytics_outlined), text: 'Estadísticas'),
            Tab(icon: Icon(Icons.gavel), text: 'Moderación'),
            Tab(icon: Icon(Icons.people_outline), text: 'Usuarios'),
            Tab(icon: Icon(Icons.category_outlined), text: 'Categorías'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: STATS
          _buildStatsTab(provider.adminStats),

          // TAB 2: MODERATION
          _buildModerationTab(provider.pendingBooks, provider),

          // TAB 3: USERS
          _buildUsersTab(provider.allUsers, provider),

          // TAB 4: CATEGORIES
          _buildCategoriesTab(provider.categories),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 3) {
            _showAddCategoryDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ve a la pestaña "Categorías" para crear una nueva')),
            );
          }
        },
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatsTab(var stats) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildStatCard('Usuarios Registrados', '${stats.totalUsers}', Icons.people, Colors.blue),
        _buildStatCard('Libros en Catálogo', '${stats.totalBooks}', Icons.book, Colors.indigo),
        _buildStatCard('Libros Pendientes', '${stats.pendingBooks}', Icons.gavel, Colors.orange),
        _buildStatCard('Libros Aprobados', '${stats.approvedBooks}', Icons.check_circle_outline, Colors.green),
        _buildStatCard('Descargas Totales', '${stats.totalDownloads}', Icons.download, Colors.purple),
        _buildStatCard('Reseñas Escritas', '${stats.totalReviews}', Icons.rate_review_outlined, Colors.teal),
        _buildStatCard('Ganancias Estimadas', 'S/. ${stats.simulatedRevenue.toStringAsFixed(2)}', Icons.monetization_on, Colors.amber[800]!),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        trailing: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildModerationTab(List<Book> books, BookShopProvider provider) {
    if (books.isEmpty) {
      return const Center(child: Text('No hay libros pendientes de moderación'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final b = books[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50,
                      height: 75,
                      color: Colors.grey[200],
                      child: b.coverUrl.isNotEmpty ? Image.network(b.coverUrl, fit: BoxFit.cover) : const Icon(Icons.book),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Autor: ${b.author}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          Text('Precio: S/. ${b.price}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          Text('Sinopsis: ${b.description}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      onPressed: () => _showRejectDialog(b.id),
                      child: const Text('Rechazar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      onPressed: () {
                        provider.approveBook(b.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Libro aprobado con éxito')),
                        );
                      },
                      child: const Text('Aprobar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersTab(List<User> users, BookShopProvider provider) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: users.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final u = users[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: u.photoUrl.isNotEmpty ? NetworkImage(u.photoUrl) : null,
            child: u.photoUrl.isEmpty ? const Icon(Icons.person) : null,
          ),
          title: Text(u.name),
          subtitle: Text('${u.email}\nRol: ${u.role.toUpperCase()} • ${u.active ? "Activo" : "Inactivo"}'),
          isThreeLine: true,
          trailing: PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'role') {
                provider.toggleUserRole(u);
              } else if (action == 'active') {
                provider.toggleUserActive(u);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'role',
                child: Text(u.isAdmin ? 'Cambiar a Lector' : 'Cambiar a Admin'),
              ),
              PopupMenuItem(
                value: 'active',
                child: Text(u.active ? 'Desactivar Cuenta' : 'Activar Cuenta'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab(List<Category> categories) {
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final c = categories[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.indigo[50],
            child: const Icon(Icons.category, color: Colors.indigo),
          ),
          title: Text(c.name),
          subtitle: Text('${c.id}\n${c.description}'),
          isThreeLine: true,
          trailing: Icon(
            c.active ? Icons.check_circle : Icons.cancel,
            color: c.active ? Colors.green : Colors.red,
          ),
        );
      },
    );
  }
}
