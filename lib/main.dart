import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/bookshop_provider.dart';
import 'data/repository/bookshop_repository.dart';
import 'data/repository/firebase_auth_repository.dart';
import 'ui/main_app_scaffold.dart';
import 'ui/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BookShopProvider(
            repository: BookShopRepository(),
            authRepository: FirebaseAuthRepository(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Robert's Book",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: Consumer<BookShopProvider>(
        builder: (context, provider, _) {
          if (provider.currentUser == null) {
            return const LoginScreen();
          }
          return const MainAppScaffold();
        },
      ),
    );
  }
}