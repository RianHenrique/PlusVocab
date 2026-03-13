import 'package:flutter/material.dart';
import 'package:plus_vocab/features/auth/views/signin_screen.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {

  void _logOut() async {

    final authController = context.read<AuthController>();

    await authController.logOut();

    if (!mounted) return;

    if (authController.errorMessage == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _logOut(), 
      child: const Text("Deslogar")
    );
  }
}