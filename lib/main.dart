import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/models/auth_service.dart';
import 'features/auth/views/signup_screen.dart';
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
        // Define a cor primária
        primarySwatch: Colors.blue,
        // Define a família de fontes padrão para todo o app
        // O pacote google_fonts cuida do download e cache da fonte.
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: const SignUpScreen(),
    );
  }
}
