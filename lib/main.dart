import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/home/controllers/progress_home_controller.dart';
import 'package:plus_vocab/features/home/models/progress_home_service.dart';
import 'package:plus_vocab/features/home/views/home_screen.dart';

import 'package:provider/provider.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/models/auth_service.dart';
import 'features/auth/views/signin_screen.dart';
import 'features/auth/views/onboarding_screen.dart';
import 'features/pratica/exercicio/data/vocab_practice_service.dart';
import 'features/temas/models/temas_service.dart';
import 'features/temas/controllers/temas_controller.dart';
import 'features/dicionario/models/dicionario_service.dart';
import 'features/dicionario/controllers/dicionario_controller.dart';
import 'features/user/models/user_service.dart';
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

        Provider<TemasService>(
          create: (context) => TemasService(context.read<ApiClient>()),
        ),

        Provider<VocabPracticeService>(
          create: (context) => VocabPracticeService(context.read<ApiClient>()),
        ),

        Provider<DicionarioService>(
          create: (context) => DicionarioService(context.read<ApiClient>()),
        ),

        Provider<UserService>(
          create: (context) => UserService(context.read<ApiClient>()),
        ),

        Provider<ProgressHomeService>(
          create: (context) => ProgressHomeService(context.read<ApiClient>()),
        ),

        // --- NÍVEL DE CONTROLLER ("C") ---
        ChangeNotifierProvider(
          create: (context) => AuthController(context.read<AuthService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => TemasController(
            context.read<TemasService>(),
            context.read<VocabPracticeService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DicionarioController(context.read<DicionarioService>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ProgressHomeController(context.read<ProgressHomeService>()),
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaria,
          primary: AppColors.primaria,
          secondary: AppColors.secundaria,
          error: AppColors.erro,
        ),
        textTheme: GoogleFonts.lexendTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: AppColors.textoPreto, displayColor: AppColors.textoPreto),
      ),
      home: FutureBuilder<bool>(
        future: context.read<AuthController>().checkAuthStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primaria),
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
              return Consumer<AuthController>(
                builder: (context, auth, _) {
                  if (auth.needsProfileOnboarding) {
                    return const OnboardingScreen();
                  }
                  return const HomeScreen();
                },
              );
            } else {
              return const SignInScreen();
            }
          }
        },
      ),
    );
  }
}