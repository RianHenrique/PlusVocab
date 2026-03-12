import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:plus_vocab/features/homePage/views/home_screen.dart';

import 'package:provider/provider.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/models/auth_service.dart';
import 'features/auth/views/signin_screen.dart';
import 'core/services/api_client.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [

        // 1. Você provê o ApiClient
        Provider<ApiClient>(
          create: (_) => ApiClient(),
        ),
  
        // 2. Você provê o AuthService e INJETA o ApiClient nele
        Provider<AuthService>(
          create: (context) => AuthService(
            // Use context.read para pegar o ApiClient
            context.read<ApiClient>(), // <-- A CORREÇÃO É ESTA LINHA
          ),
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
      home: const SignInScreen(),
    );
  }
}