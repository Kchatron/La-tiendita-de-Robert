import 'dart:io';
import 'package:flutter/material.dart';
import '../../../data/models/book.dart';
import '../../../data/repository/pdf_manager.dart';

class PdfReaderScreen extends StatefulWidget {
  final Book book;

  const PdfReaderScreen({super.key, required this.book});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final _pdfManager = PdfManager();
  String _fileContent = 'Cargando contenido del libro...';
  bool _isLoading = true;
  double _fontSize = 16.0;
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      final file = await _pdfManager.getPdfFile(widget.book);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          _fileContent = content;
          _isLoading = false;
        });
      } else {
        // Generate it first if somehow missing
        final generatedFile = await _pdfManager.generateSamplePdf(widget.book);
        final content = await generatedFile.readAsString();
        setState(() {
          _fileContent = content;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _fileContent = 'Error al abrir el libro:\n$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _isDarkTheme ? Colors.grey[950]! : Colors.amber[50]!;
    final textColor = _isDarkTheme ? Colors.grey[200]! : Colors.brown[900]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.book.title, style: const TextStyle(fontSize: 16)),
        backgroundColor: _isDarkTheme ? Colors.grey[900]! : Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Toggle Theme
          IconButton(
            icon: Icon(_isDarkTheme ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Cambiar Tema',
            onPressed: () {
              setState(() {
                _isDarkTheme = !_isDarkTheme;
              });
            },
          ),
          // Increase Font Size
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: 'Aumentar texto',
            onPressed: () {
              setState(() {
                if (_fontSize < 30.0) _fontSize += 2.0;
              });
            },
          ),
          // Decrease Font Size
          IconButton(
            icon: const Icon(Icons.text_decrease),
            tooltip: 'Disminuir texto',
            onPressed: () {
              setState(() {
                if (_fontSize > 12.0) _fontSize -= 2.0;
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.book.title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _fontSize + 4,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Por ${widget.book.author}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _fontSize - 2,
                      fontStyle: FontStyle.italic,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Divider(color: textColor.withOpacity(0.3), thickness: 1.5),
                  const SizedBox(height: 16),
                  Text(
                    _fileContent,
                    style: TextStyle(
                      fontSize: _fontSize,
                      height: 1.6,
                      color: textColor,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
