import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/book.dart';

class PdfManager {
  Future<String> getPdfDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory(p.join(docDir.path, 'books'));
    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }
    return pdfDir.path;
  }

  Future<File> getPdfFile(Book book) async {
    final dir = await getPdfDir();
    final safeName = book.pdfFileName.isEmpty ? 'book_${book.id}.pdf' : book.pdfFileName;
    return File(p.join(dir, safeName));
  }

  Future<bool> isPdfDownloaded(Book book) async {
    final file = await getPdfFile(book);
    return await file.exists() && await file.length() > 0;
  }

  Future<File> generateSamplePdf(Book book) async {
    final file = await getPdfFile(book);
    if (await file.exists() && await file.length() > 0) return file;

    // We write a simple text content representing the book that our reader can parse
    final buffer = StringBuffer();
    buffer.writeln("BOOKSHOP - EDICIÓN DIGITAL");
    buffer.writeln("-----------------------------------------");
    buffer.writeln("Título: ${book.title}");
    buffer.writeln("Autor: ${book.author}");
    buffer.writeln("Categoría: ${book.categoryId}");
    buffer.writeln("ISBN: ${book.isbn}");
    buffer.writeln("Año: ${book.publicationYear}");
    buffer.writeln("Páginas: ${book.pageCount}");
    buffer.writeln("Idioma: ${book.language}");
    buffer.writeln("-----------------------------------------");
    buffer.writeln("SINOPSIS:");
    buffer.writeln(book.description);
    buffer.writeln("-----------------------------------------");
    buffer.writeln("CONTENIDO DE MUESTRA (CAPÍTULO 1):");
    buffer.writeln("Este es el inicio de la versión digital autorizada para ${book.title}.");
    buffer.writeln("Los conceptos explicados por el autor ${book.author} detallan las metodologías y mejores prácticas del área.");
    buffer.writeln("Fin del capítulo de muestra.");

    await file.writeAsString(buffer.toString());
    return file;
  }

  Future<void> deletePdf(Book book) async {
    final file = await getPdfFile(book);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
