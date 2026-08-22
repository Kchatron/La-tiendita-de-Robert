import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/bookshop_provider.dart';
import '../../../data/models/user.dart';
import 'my_purchases_screen.dart';
import 'preferences_screen.dart';
import '../publishing/my_publications_screen.dart';
import '../author/author_screens.dart';
import '../admin/admin_screens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _photoController = TextEditingController();

  void _showEditProfileDialog(User user) {
    _nameController.text = user.name;
    _bioController.text = user.bio;
    _photoController.text = user.photoUrl;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Biografía (Agrega para ser autor)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _photoController,
                  decoration: const InputDecoration(labelText: 'URL de Foto de Perfil'),
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
                final provider = Provider.of<BookShopProvider>(context, listen: false);
                provider.updateUserProfile(
                  _nameController.text,
                  _bioController.text,
                  _photoController.text,
                );
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil actualizado con éxito')),
                );
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookShopProvider>(context);
    final user = provider.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Inicia sesión para ver tu perfil')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                    radius: 48,
                    child: user.photoUrl.isEmpty ? const Icon(Icons.person, size: 48) : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  if (user.bio.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      user.bio,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[800], fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ],
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _showEditProfileDialog(user),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar Perfil'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Menu Options
          Text('Opciones de Usuario', style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[700])),
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.history_edu, color: Colors.indigo),
            title: const Text('Mis Preferencias'),
            subtitle: const Text('Cambiar géneros preferidos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PreferencesScreen()),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined, color: Colors.indigo),
            title: const Text('Mis Compras'),
            subtitle: const Text('Historial de libros adquiridos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MyPurchasesScreen()),
              );
            },
          ),
          const Divider(),

          if (user.isAuthor) ...[
            ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.amber),
              title: const Text('Panel de Autor'),
              subtitle: const Text('Publicar libros y ver ganancias'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyPublicationsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.insights, color: Colors.amber),
              title: const Text('Estadísticas de Autor'),
              subtitle: const Text('Consulta tus vistas, descargas e ingresos'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AuthorStatsScreen()),
              ),
            ),
            const Divider(),
          ] else ...[
            ListTile(
              leading: const Icon(Icons.menu_book_outlined, color: Colors.grey),
              title: const Text('Convertirse en Autor'),
              subtitle: const Text('Agrega una biografía en tu perfil para publicar'),
              onTap: () => _showEditProfileDialog(user),
            ),
            const Divider(),
          ],

          if (user.isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
              title: const Text('Panel de Administración'),
              subtitle: const Text('Moderación de libros, categorías y usuarios'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminScreens()),
                );
              },
            ),
            const Divider(),
          ],

          // Quick admin toggle (for testing)
          SwitchListTile(
            title: const Text('Modo Administrador (Simulado)'),
            subtitle: const Text('Habilitar o deshabilitar opciones admin'),
            value: user.isAdmin,
            onChanged: (val) {
              provider.toggleAdminRole();
            },
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => provider.logout(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[800],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
