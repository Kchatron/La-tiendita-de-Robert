import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'data/repository/bookshop_repository.dart';
import 'data/repository/firebase_auth_repository.dart';
import 'providers/bookshop_provider.dart';
import 'ui/main_app_scaffold.dart';

void main() async {
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BookShopProvider(
            repository: BookShopRepository(),
            authRepository: FirebaseAuthRepository(),
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
        ),
        home: const MainAppScaffold(),
      ),
    );
  }
}