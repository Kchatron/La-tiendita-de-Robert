import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../models/book.dart';
import '../models/category.dart';
import '../models/review.dart';
import '../models/transactions_and_stats.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bookshop.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerNullable = 'INTEGER';
    const realType = 'REAL NOT NULL';

    // 1. Users Table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name $textType,
        email $textType,
        photoUrl $textType,
        bio $textType,
        role $textType,
        preferences $textType,
        createdAt $integerType,
        active $integerType
      )
    ''');

    // 2. Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name $textType,
        iconName $textType,
        description $textType,
        active $integerType
      )
    ''');

    // 3. Books Table
    await db.execute('''
      CREATE TABLE books (
        id TEXT PRIMARY KEY,
        title $textType,
        description $textType,
        author $textType,
        authorId $textType,
        categoryId $textType,
        coverUrl $textType,
        pdfStoragePath $textType,
        pdfFileName $textType,
        fileSizeMb $realType,
        price $realType,
        language $textType,
        publicationYear $integerType,
        isbn $textType,
        pageCount $integerType,
        ratingAverage $realType,
        ratingCount $integerType,
        viewCount $integerType,
        downloadCount $integerType,
        status $textType,
        rejectionReason $textNullable,
        createdAt $integerType,
        updatedAt $integerType,
        approvedAt $integerNullable
      )
    ''');

    // 4. Reviews Table
    await db.execute('''
      CREATE TABLE reviews (
        id TEXT PRIMARY KEY,
        userId $textType,
        userName $textType,
        userPhoto $textType,
        bookId $textType,
        rating $integerType,
        comment $textType,
        createdAt $integerType
      )
    ''');

    // 5. Library Table
    await db.execute('''
      CREATE TABLE library (
        id TEXT PRIMARY KEY,
        userId $textType,
        bookId $textType,
        source $textType,
        acquiredAt $integerType,
        isDownloaded $integerType,
        downloadedAt $integerType,
        localFilePath $textNullable
      )
    ''');

    // 6. Purchases Table
    await db.execute('''
      CREATE TABLE purchases (
        id TEXT PRIMARY KEY,
        userId $textType,
        bookId $textType,
        bookTitle $textType,
        bookCover $textType,
        price $realType,
        paymentMethod $textType,
        paymentStatus $textType,
        createdAt $integerType
      )
    ''');

    // 7. Favorites Table
    await db.execute('''
      CREATE TABLE favorites (
        id TEXT PRIMARY KEY,
        userId $textType,
        bookId $textType,
        createdAt $integerType
      )
    ''');

    // Seed Initial Demo Data
    await _seedDemoData(db);
  }

  Future _seedDemoData(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Users
    final defaultUser = User(
      id: 'user_demo_01',
      name: 'Carlos Méndez',
      email: 'user@bookshop.demo',
      photoUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
      bio: 'Lector apasionado de tecnología, desarrollo de software y ciencia ficción.',
      role: User.ROLE_USER,
      preferences: ['Programación', 'Inteligencia Artificial', 'Ciencia Ficción'],
      createdAt: now - 86400000 * 30,
    );

    final adminUser = User(
      id: 'user_admin_01',
      name: 'Elena Valenzuela',
      email: 'admin@bookshop.demo',
      photoUrl: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&q=80',
      bio: 'Administradora General y Moderadora de Contenido en BookShop.',
      role: User.ROLE_ADMIN,
      preferences: ['Programación', 'Finanzas', 'Desarrollo Personal'],
      createdAt: now - 86400000 * 90,
    );

    final authorUser = User(
      id: 'author_gabriel_01',
      name: 'Gabriel Vargas',
      email: 'author@bookshop.demo',
      photoUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&q=80',
      bio: 'Arquitecto de Software y autor de best-sellers técnicos sobre Android, Kotlin y Sistemas Distribuidos.',
      role: User.ROLE_USER,
      preferences: ['Programación', 'Inteligencia Artificial'],
      createdAt: now - 86400000 * 120,
    );

    await db.insert('users', defaultUser.toMap());
    await db.insert('users', adminUser.toMap());
    await db.insert('users', authorUser.toMap());

    // Categories
    final categoriesList = [
      Category(id: 'cat_prog', name: 'Programación', iconName: 'code', description: 'Kotlin, Java, Python, Arquitectura y buenas prácticas.'),
      Category(id: 'cat_ai', name: 'Inteligencia Artificial', iconName: 'memory', description: 'Machine Learning, Deep Learning, LLMs y Redes Neuronales.'),
      Category(id: 'cat_fin', name: 'Finanzas y Negocios', iconName: 'trending_up', description: 'Emprendimiento, inversiones, economía moderna y liderazgo.'),
      Category(id: 'cat_sci', name: 'Ciencia Ficción', iconName: 'rocket_launch', description: 'Novelas futuristas, exploración espacial y cyberpunk.'),
      Category(id: 'cat_self', name: 'Desarrollo Personal', iconName: 'self_improvement', description: 'Hábitos atómicos, productividad, mentalidad y bienestar.'),
      Category(id: 'cat_hist', name: 'Historia y Cultura', iconName: 'history_edu', description: 'Grandes civilizaciones, hitos históricos y biografías.'),
      Category(id: 'cat_lit', name: 'Literatura Clásica', iconName: 'auto_stories', description: 'Obras maestras universales y contemporáneas.'),
      Category(id: 'cat_design', name: 'Diseño & UX', iconName: 'palette', description: 'Diseño de interfaces, experiencia de usuario y accesibilidad.'),
    ];

    for (var cat in categoriesList) {
      await db.insert('categories', cat.toMap());
    }

    // Books
    final booksList = [
      Book(
        id: 'book_01',
        title: 'Arquitectura Limpia en Kotlin y Compose',
        description: 'Domina el desarrollo moderno en Android implementando Clean Architecture, StateFlow, Coroutines y Jetpack Compose con un enfoque profesional para aplicaciones escalables.',
        author: 'Gabriel Vargas',
        authorId: 'author_gabriel_01',
        categoryId: 'cat_prog',
        coverUrl: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600&q=80',
        pdfStoragePath: '/books/book_01.pdf',
        pdfFileName: 'arquitectura_limpia_kotlin.pdf',
        fileSizeMb: 14.8,
        price: 19.99,
        language: 'Español',
        publicationYear: 2024,
        isbn: '978-0134494166',
        pageCount: 384,
        ratingAverage: 4.9,
        ratingCount: 84,
        viewCount: 1420,
        downloadCount: 512,
        status: Book.STATUS_APPROVED,
        createdAt: now - 86400000 * 15,
        updatedAt: now - 86400000 * 15,
        approvedAt: now - 86400000 * 14,
      ),
      Book(
        id: 'book_02',
        title: 'Guía Práctica de Inteligencia Artificial Generativa',
        description: 'Aprende los fundamentos de los Modelos de Lenguaje (LLMs), Transformers, RAG (Retrieval-Augmented Generation) y Prompt Engineering aplicado al desarrollo de software actual.',
        author: 'Dra. Sofía Morales',
        authorId: 'author_sofia_02',
        categoryId: 'cat_ai',
        coverUrl: 'https://images.unsplash.com/photo-1677442136019-21780efad99a?w=600&q=80',
        pdfStoragePath: '/books/book_02.pdf',
        pdfFileName: 'ia_generativa_practica.pdf',
        fileSizeMb: 22.4,
        price: 24.50,
        language: 'Español',
        publicationYear: 2024,
        isbn: '978-1491954249',
        pageCount: 420,
        ratingAverage: 4.8,
        ratingCount: 120,
        viewCount: 2890,
        downloadCount: 890,
        status: Book.STATUS_APPROVED,
        createdAt: now - 86400000 * 28,
        updatedAt: now - 86400000 * 28,
        approvedAt: now - 86400000 * 27,
      ),
      Book(
        id: 'book_03',
        title: 'Introducción al Código Abierto y Git',
        description: 'Un libro completo y 100% gratuito para principiantes que desean dominar el control de versiones con Git, GitHub y colaborar en proyectos Open Source de todo el mundo.',
        author: 'Comunidad Open Dev',
        authorId: 'author_opendev_03',
        categoryId: 'cat_prog',
        coverUrl: 'https://images.unsplash.com/photo-1618401471353-b98afee0b2eb?w=600&q=80',
        pdfStoragePath: '/books/book_03.pdf',
        pdfFileName: 'intro_git_opensource.pdf',
        fileSizeMb: 8.5,
        price: 0.0,
        language: 'Español',
        publicationYear: 2023,
        isbn: '978-0201616224',
        pageCount: 196,
        ratingAverage: 4.9,
        ratingCount: 310,
        viewCount: 5600,
        downloadCount: 2450,
        status: Book.STATUS_APPROVED,
        createdAt: now - 86400000 * 60,
        updatedAt: now - 86400000 * 60,
        approvedAt: now - 86400000 * 59,
      ),
      Book(
        id: 'book_04',
        title: 'Estrategias de Inversión y Finanzas Personales',
        description: 'Aprende a construir tu patrimonio personal, gestionar presupuestos, invertir con prudencia en fondos indexados y alcanzar la libertad financiera a largo plazo.',
        author: 'Roberto Alcázar',
        authorId: 'author_roberto_04',
        categoryId: 'cat_fin',
        coverUrl: 'https://images.unsplash.com/photo-1590283603385-17ffb3a7f29f?w=600&q=80',
        pdfStoragePath: '/books/book_04.pdf',
        pdfFileName: 'estrategias_inversion_finanzas.pdf',
        fileSizeMb: 11.2,
        price: 15.00,
        language: 'Español',
        publicationYear: 2023,
        isbn: '978-0060555665',
        pageCount: 280,
        ratingAverage: 4.7,
        ratingCount: 95,
        viewCount: 1980,
        downloadCount: 630,
        status: Book.STATUS_APPROVED,
        createdAt: now - 86400000 * 45,
        updatedAt: now - 86400000 * 45,
        approvedAt: now - 86400000 * 44,
      ),
      Book(
        id: 'book_05',
        title: 'Crónicas de la Estación Orbital Omega',
        description: 'Año 2184. En el límite del sistema solar, una estación de minería cuántica descubre una señal de origen desconocido que desafía las leyes de la física relativista.',
        author: 'Lucía Santander',
        authorId: 'author_lucia_05',
        categoryId: 'cat_sci',
        coverUrl: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&q=80',
        pdfStoragePath: '/books/book_05.pdf',
        pdfFileName: 'cronicas_estacion_omega.pdf',
        fileSizeMb: 16.0,
        price: 12.99,
        language: 'Español',
        publicationYear: 2024,
        isbn: '978-0765382030',
        pageCount: 350,
        ratingAverage: 4.8,
        ratingCount: 64,
        viewCount: 1350,
        downloadCount: 410,
        status: Book.STATUS_APPROVED,
        createdAt: now - 86400000 * 20,
        updatedAt: now - 86400000 * 20,
        approvedAt: now - 86400000 * 19,
      ),
      Book(
        id: 'book_06',
        title: 'El Hábito del Enfoque Profundo',
        description: 'Estrategias prácticas para eliminar la distracción digital, cultivar la atención plena y alcanzar niveles de alta productividad en el trabajo y el estudio.',
        author: 'Andrés Carrillo',
        authorId: 'author_andres_06',
        categoryId: 'cat_self',
        coverUrl: 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=600&q=80',
        pdfStoragePath: '/books/book_06.pdf',
        pdfFileName: 'habito_enfoque_profundo.pdf',
        fileSizeMb: 9.8,
        price: 9.99,
        language: 'Español',
        publicationYear: 2023,
        isbn: '978-1455586691',
        pageCount: 240,
        ratingAverage: 4.6,
        ratingCount: 78,
        viewCount: 1670,
        downloadCount: 520,
        status: Book.STATUS_APPROVED,
        createdAt: now - 86400000 * 35,
        updatedAt: now - 86400000 * 35,
        approvedAt: now - 86400000 * 34,
      ),
      Book(
        id: 'book_07',
        title: 'Don Quijote de la Mancha (Edición Completa)',
        description: 'La inmortal obra cumbre de la literatura en lengua española por Miguel de Cervantes Saavedra, bellamente formateada en versión digital y de acceso libre.',
        author: 'Miguel de Cervantes',
        authorId: 'author_cervantes_07',
        categoryId: 'cat_lit',
        coverUrl: 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=600&q=80',
        pdfStoragePath: '/books/book_07.pdf',
        pdfFileName: 'don_quijote_cervantes.pdf',
        fileSizeMb: 18.2,
        price: 0.0,
        language: 'Español',
        publicationYear: 1605,
        isbn: '978-8420412146',
        pageCount: 860,
        ratingAverage: 5.0,
        ratingCount: 450,
        viewCount: 8900,
        downloadCount: 3890,
        status: Book.STATUS_APPROVED,
        createdAt: now - 86400000 * 100,
        updatedAt: now - 86400000 * 100,
        approvedAt: now - 86400000 * 99,
      ),
      Book(
        id: 'book_08',
        title: 'Diseño de Interfaces Centrado en el Usuario (UX/UI)',
        description: 'Principios de diseño visual, jerarquía tipográfica, heurísticas de usabilidad y sistemas de diseño como Material Design 3.',
        author: 'Mariana Ríos',
        authorId: 'author_mariana_08',
        categoryId: 'cat_design',
        coverUrl: 'https://images.unsplash.com/photo-1581291518857-4e27b48ff24e?w=600&q=80',
        pdfStoragePath: '/books/book_08.pdf',
        pdfFileName: 'diseno_ux_ui_m3.pdf',
        fileSizeMb: 26.5,
        price: 18.50,
        language: 'Español',
        publicationYear: 2024,
        isbn: '978-0134857213',
        pageCount: 310,
        ratingAverage: 4.9,
        ratingCount: 88,
        viewCount: 2100,
        downloadCount: 740,
        status: Book.STATUS_APPROVED,
        createdAt: now - 86400000 * 12,
        updatedAt: now - 86400000 * 12,
        approvedAt: now - 86400000 * 11,
      ),
      Book(
        id: 'book_09',
        title: 'Microservicios Reactivos con Kotlin y Ktor',
        description: 'Un manuscrito avanzado sobre construcción de microservicios asíncronos y resilientes utilizando Ktor, Coroutines y Docker en la nube.',
        author: 'Gabriel Vargas',
        authorId: 'author_gabriel_01',
        categoryId: 'cat_prog',
        coverUrl: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&q=80',
        pdfStoragePath: '/books/book_09.pdf',
        pdfFileName: 'microservicios_ktor_manuscrito.pdf',
        fileSizeMb: 17.5,
        price: 22.00,
        language: 'Español',
        publicationYear: 2024,
        isbn: '978-0132350884',
        pageCount: 320,
        ratingAverage: 0.0,
        ratingCount: 0,
        viewCount: 45,
        downloadCount: 0,
        status: Book.STATUS_PENDING,
        createdAt: now - 86400000 * 2,
        updatedAt: now - 86400000 * 2,
      ),
      Book(
        id: 'book_10',
        title: 'Ciberseguridad Práctica para Desarrolladores',
        description: 'Protege tus aplicaciones contra las principales vulnerabilidades OWASP Top 10, autenticación OAuth2, criptografía aplicada y auditorías de seguridad.',
        author: 'Fernando Toledo',
        authorId: 'author_fernando_10',
        categoryId: 'cat_prog',
        coverUrl: 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=600&q=80',
        pdfStoragePath: '/books/book_10.pdf',
        pdfFileName: 'ciberseguridad_practica.pdf',
        fileSizeMb: 15.3,
        price: 16.75,
        language: 'Español',
        publicationYear: 2024,
        isbn: '978-1593279929',
        pageCount: 290,
        ratingAverage: 4.7,
        ratingCount: 42,
        viewCount: 980,
        downloadCount: 320,
        status: Book.STATUS_APPROVED,
        createdAt: now - 86400000 * 8,
        updatedAt: now - 86400000 * 8,
        approvedAt: now - 86400000 * 7,
      ),
    ];

    for (var book in booksList) {
      await db.insert('books', book.toMap());
    }

    // Reviews
    final reviewsList = [
      Review(
        id: 'rev_01',
        bookId: 'book_01',
        userId: 'user_demo_01',
        userName: 'Carlos Méndez',
        userPhoto: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
        rating: 5,
        comment: '¡Increíble libro! Los ejemplos de Clean Architecture con Jetpack Compose son súper claros y me ayudaron directamente en mi proyecto laboral.',
        createdAt: now - 86400000 * 5,
      ),
      Review(
        id: 'rev_02',
        bookId: 'book_01',
        userId: 'user_admin_01',
        userName: 'Elena Valenzuela',
        userPhoto: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400&q=80',
        rating: 5,
        comment: 'Excelente material de referencia. La calidad pedagógica del autor Gabriel Vargas es de primer nivel.',
        createdAt: now - 86400000 * 8,
      ),
      Review(
        id: 'rev_03',
        bookId: 'book_02',
        userId: 'user_demo_01',
        userName: 'Carlos Méndez',
        userPhoto: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
        rating: 5,
        comment: 'Muy actualizado con las últimas técnicas de RAG y Prompt Engineering. Lectura obligatoria en 2024.',
        createdAt: now - 86400000 * 10,
      ),
      Review(
        id: 'rev_04',
        bookId: 'book_03',
        userId: 'user_demo_01',
        userName: 'Carlos Méndez',
        userPhoto: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400&q=80',
        rating: 5,
        comment: 'Increíble que este libro sea 100% gratuito. Muy completo y fácil de seguir para principiantes.',
        createdAt: now - 86400000 * 14,
      ),
    ];

    for (var rev in reviewsList) {
      await db.insert('reviews', rev.toMap());
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
