import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/features/homePage/views/home_screen.dart';

import 'package:provider/provider.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/models/auth_service.dart';
import 'features/auth/views/signin_screen.dart';
import 'core/services/api_client.dart';
import 'core/services/storage_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [

        // 1. Você provê o ApiClient
        Provider<ApiClient>(
          create: (_) => ApiClient(),
        ),

        Provider<StorageService>(
          create: (_) => StorageService(),
        ),
  
        // 2. Você provê o AuthService e INJETA o ApiClient nele
        Provider<AuthService>(
          create: (context) {
            final apiClient = context.read<ApiClient>();
            final storage = context.read<StorageService>();

            final authService = AuthService(apiClient, storage);

            apiClient.addAuthInterceptor(authService);

            return authService;
            // // Use context.read para pegar o ApiClient
            // context.read<ApiClient>(), // <-- A CORREÇÃO É ESTA LINHA
            // context.read<StorageService>(),
          },
        ),

        // --- NÍVEL DE CONTROLLER ("C") ---
        // Provê o AuthController, que DEPENDE do AuthService
        ChangeNotifierProvider(
          create: (context) => AuthController(
            // Usa 'context.read' para pegar o AuthService que acabamos de prover
            context.read<AuthService>(),
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
      title: 'MyApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.lexendTextTheme(Theme.of(context).textTheme),
      ),
      home: FutureBuilder<bool>(
        future: context.read<AuthController>().checkAuthStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text('Erro ao verificar status de autenticação.'),
              ),
            );
          } else {
            final isAuthenticated = snapshot.data ?? false;
            if (isAuthenticated) {
              // return const HomeScreen();
              return const HomeScreen(); // Substitua pelo seu HomeScreen real
            } else {
              return const SignInScreen();
            }
          }
        },
      ),
    );
  }
}