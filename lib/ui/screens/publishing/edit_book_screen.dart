import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/bookshop_provider.dart';
import '../../../data/models/book.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _pagesController;
  late TextEditingController _isbnController;

  String _selectedCategoryId = '';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book.title);
    _descController = TextEditingController(text: widget.book.description);
    _priceController = TextEditingController(text: widget.book.price.toString());
    _pagesController = TextEditingController(text: widget.book.pageCount.toString());
    _isbnController = TextEditingController(text: widget.book.isbn);
    _selectedCategoryId = widget.book.categoryId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _pagesController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<BookShopProvider>(context, listen: false);
    provider.editBook(
      bookId: widget.book.id,
      title: _titleController.text,
      description: _descController.text,
      categoryId: _selectedCategoryId,
      price: double.tryParse(_priceController.text) ?? 0.0,
      pageCount: int.tryParse(_pagesController.text) ?? 100,
      isbn: _isbnController.text,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edición guardada. Libro enviado a revisión')),
        );
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<BookShopProvider>(context).categories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Libro'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título del Libro', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa el título' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Sinopsis / Descripción', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'Ingresa la sinopsis' : null,
              ),
              const SizedBox(height: 16),

              // Category Selector
              DropdownButtonFormField<String>(
                value: _selectedCategoryId.isNotEmpty ? _selectedCategoryId : null,
                decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
                items: categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat.id,
                    child: Text(cat.name),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategoryId = val!;
                  });
                },
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio (S/.)', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Ingresa el precio' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _pagesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Número de Páginas', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Ingresa las páginas' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(labelText: 'ISBN', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Guardar y Re-evaluar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
