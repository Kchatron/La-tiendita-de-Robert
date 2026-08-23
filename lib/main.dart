import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/local/db_helper.dart';
import 'data/repository/bookshop_repository.dart';
import 'data/repository/firebase_auth_repository.dart';
import 'data/repository/pdf_manager.dart';
import 'firebase_options.dart';
import 'providers/bookshop_provider.dart';
import 'ui/main_app_scaffold.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialise databases & repositories
    final dbHelper = DbHelper.instance;
    final pdfManager = PdfManager();
    final authRepository = FirebaseAuthRepository(dbHelper: dbHelper);
    final bookShopRepository = BookShopRepository(
      dbHelper: dbHelper,
      pdfManager: pdfManager,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BookShopProvider>(
          create: (_) => BookShopProvider(
            authRepository: authRepository,
            bookShopRepository: bookShopRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'BookShop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            primary: Colors.indigo,
            secondary: Colors.amber,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          navigationBarTheme: NavigationBarThemeData(
            indicatorColor: Colors.indigo.withOpacity(0.15),
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        home: const MainApp(),
      ),
    );
  }
}
