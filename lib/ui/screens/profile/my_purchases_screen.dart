import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../providers/bookshop_provider.dart';

class MyPurchasesScreen extends StatelessWidget {
  const MyPurchasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BookShopProvider>(context);
    final purchases = provider.myPurchases;
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Compras'),
      ),
      body: purchases.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes compras registradas',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: purchases.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final p = purchases[index];
                final dateStr = dateFormat.format(DateTime.fromMillisecondsSinceEpoch(p.createdAt));

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book Cover
                    Container(
                      width: 60,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: p.bookCover.isNotEmpty
                          ? Image.network(
                              p.bookCover,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.book, size: 24, color: Colors.grey),
                            )
                          : const Icon(Icons.book, size: 24, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),

                    // Purchase info details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.bookTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Transacción: ${p.id}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                          Text(
                            'Fecha: $dateStr',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                          Text(
                            'Pago: ${p.paymentMethod} • Estado: ${p.paymentStatus}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.price <= 0.0 ? 'Gratis' : 'S/. ${p.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: p.price <= 0.0 ? Colors.green : theme.colorScheme.primary,
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
