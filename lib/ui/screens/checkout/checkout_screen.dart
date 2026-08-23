import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/bookshop_provider.dart';
import '../../../data/models/book.dart';

class CheckoutScreen extends StatefulWidget {
  final Book book;

  const CheckoutScreen({super.key, required this.book});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'Tarjeta';
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _cardNumberController.dispose();
    super.dispose();
  }

  void _processPayment() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<BookShopProvider>(context, listen: false);
    provider.purchaseBook(
      widget.book,
      _selectedPaymentMethod,
      onSuccess: (purchase) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Compra Exitosa'),
                ],
              ),
              content: Text(
                'Has adquirido "${widget.book.title}" por S/. ${widget.book.price.toStringAsFixed(2)}. Ya está disponible en tu biblioteca.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Back from Checkout
                  },
                  child: const Text('Entendido'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasarela de Pago'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // BANNER INFORMATIVO PARA ENTORNO ACADÉMICO
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Proyecto Académico: Transacción de prueba (sin cargos reales).',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Book Summary Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 75,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: widget.book.coverUrl.isNotEmpty
                            ? Image.network(widget.book.coverUrl, fit: BoxFit.cover)
                            : const Icon(Icons.book),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.book.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Autor: ${widget.book.author}',
                              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Precio: S/. ${widget.book.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Method selection
              Text(
                'Método de Pago',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ListTile(
                leading: Radio<String>(
                  value: 'Tarjeta',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (val) {
                    setState(() {
                      _selectedPaymentMethod = val!;
                    });
                  },
                ),
                title: const Row(
                  children: [
                    Icon(Icons.credit_card),
                    SizedBox(width: 8),
                    Text('Tarjeta de Crédito / Débito'),
                  ],
                ),
              ),
              ListTile(
                leading: Radio<String>(
                  value: 'Yape',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (val) {
                    setState(() {
                      _selectedPaymentMethod = val!;
                    });
                  },
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      color: Colors.purple[800],
                      child: const Text('YAPE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Yape (Transferencia Directa)'),
                  ],
                ),
              ),
              ListTile(
                leading: Radio<String>(
                  value: 'Plin',
                  groupValue: _selectedPaymentMethod,
                  onChanged: (val) {
                    setState(() {
                      _selectedPaymentMethod = val!;
                    });
                  },
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      color: Colors.teal[800],
                      child: const Text('PLIN', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    const Text('Plin (Transferencia Celular)'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Payment Details Inputs
              if (_selectedPaymentMethod == 'Tarjeta') ...[
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Número de Tarjeta',
                    prefixIcon: Icon(Icons.credit_card_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 16) {
                      return 'Por favor ingresa un número de tarjeta válido (16 dígitos)';
                    }
                    return null;
                  },
                ),
              ] else ...[
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Número de Celular vinculado',
                    prefixIcon: Icon(Icons.phone_android),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 9) {
                      return 'Por favor ingresa un número de celular válido (9 dígitos)';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 32),

              // Checkout Button
              ElevatedButton(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'Confirmar Compra de Demostración: S/. ${widget.book.price.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}