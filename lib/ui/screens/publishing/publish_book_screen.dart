import 'package:flutter/material.dart' hide Category;
import 'package:provider/provider.dart';
import '../../../providers/bookshop_provider.dart';
import '../../../data/models/category.dart';

class PublishBookScreen extends StatefulWidget {
  const PublishBookScreen({super.key});

  @override
  State<PublishBookScreen> createState() => _PublishBookScreenState();
}

class _PublishBookScreenState extends State<PublishBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _coverController = TextEditingController();
  final _pdfFileController = TextEditingController(text: 'manuscrito_digital.pdf');
  final _sizeController = TextEditingController(text: '4.2');
  final _priceController = TextEditingController(text: '0.0');
  final _langController = TextEditingController(text: 'Español');
  final _yearController = TextEditingController(text: DateTime.now().year.toString());
  final _isbnController = TextEditingController();
  final _pagesController = TextEditingController(text: '120');

  String _selectedCategoryId = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final categories = Provider.of<BookShopProvider>(context).categories;
    if (_selectedCategoryId.isEmpty && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _coverController.dispose();
    _pdfFileController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _langController.dispose();
    _yearController.dispose();
    _isbnController.dispose();
    _pagesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<BookShopProvider>(context, listen: false);
    provider.publishBook(
      title: _titleController.text,
      description: _descController.text,
      categoryId: _selectedCategoryId,
      coverUrl: _coverController.text,
      pdfFileName: _pdfFileController.text,
      fileSizeMb: double.tryParse(_sizeController.text) ?? 3.5,
      price: double.tryParse(_priceController.text) ?? 0.0,
      language: _langController.text,
      publicationYear: int.tryParse(_yearController.text) ?? DateTime.now().year,
      isbn: _isbnController.text,
      pageCount: int.tryParse(_pagesController.text) ?? 100,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Libro enviado a revisión por el administrador')),
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
        title: const Text('Publicar Libro'),
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

              TextFormField(
                controller: _coverController,
                decoration: const InputDecoration(
                  labelText: 'URL de la Portada (Imagen Unsplash)',
                  hintText: 'https://images.unsplash.com/...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio (S/.)', hintText: '0.00 para gratis', border: OutlineInputBorder()),
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

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sizeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Tamaño (MB)', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Ingresa el tamaño en MB' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Año Publicación', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Ingresa el año' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _langController,
                      decoration: const InputDecoration(labelText: 'Idioma', border: OutlineInputBorder()),
                      validator: (value) => value == null || value.isEmpty ? 'Ingresa el idioma' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _isbnController,
                      decoration: const InputDecoration(labelText: 'ISBN', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _pdfFileController,
                decoration: const InputDecoration(labelText: 'Nombre del Archivo PDF', border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? 'Ingresa el nombre del archivo' : null,
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
                child: const Text('Enviar para Aprobación', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
