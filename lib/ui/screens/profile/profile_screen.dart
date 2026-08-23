import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/bookshop_provider.dart';
import '../publishing/my_publications_screen.dart';
import 'my_purchases_screen.dart';
import 'preferences_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookShopProvider>(context);
    final user = provider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 40,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            user.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Mis Compras'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPurchasesScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.book_outlined),
            title: const Text('Mis Publicaciones'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyPublicationsScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Preferencias'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PreferencesScreen()),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await provider.authRepository.signOut();
            },
          ),
        ],
      ),
    );
  }
}