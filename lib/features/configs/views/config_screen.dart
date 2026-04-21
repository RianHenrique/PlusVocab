import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/auth/views/signin_screen.dart';
import 'package:plus_vocab/features/configs/views/about_screen.dart';
import 'package:plus_vocab/features/home/views/home_screen.dart';
import 'package:plus_vocab/features/temas/views/temas_screen.dart';
import 'package:plus_vocab/features/dicionario/views/dicionario_screen.dart';
import 'package:provider/provider.dart';

import '../../auth/controllers/auth_controller.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool _isLoggingOut = false;

  String _displayNameFromEmail(String? email) {
    if (email == null || email.isEmpty) return 'Usuário';
    final at = email.indexOf('@');
    final local = at > 0 ? email.substring(0, at) : email;
    final parts = local.split(RegExp(r'[._\-+]+')).where((s) => s.isNotEmpty);
    return parts
        .map(
          (s) =>
              s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}' : '',
        )
        .where((s) => s.isNotEmpty)
        .join(' ');
  }

  Future<void> _logOut() async {
    setState(() => _isLoggingOut = true);

    final authController = context.read<AuthController>();

    await authController.logOut();

    if (!mounted) return;

    setState(() => _isLoggingOut = false);

    if (authController.errorMessage == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authController.errorMessage!)),
      );
    }
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _notImplemented(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label — em breve.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final email = auth.currentUser?.email ?? '';
    final displayName = _displayNameFromEmail(email.isEmpty ? null : email);

    return Scaffold(
      backgroundColor: AppColors.branco,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.25),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  _buildProfile(displayName, email),
                  const SizedBox(height: 32),
                  _buildMenuCard(
                    children: [
                      _MenuRow(
                        title: 'Temas',
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (context) => const TemasScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuRow(
                        title: 'Progresso',
                        onTap: () => _notImplemented('Progresso'),
                      ),
                      _MenuRow(
                        title: 'Dicionário pessoal',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => const DicionarioScreen()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Informações de conta',
                      style: GoogleFonts.lexend(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textoSuave,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildMenuCard(
                    children: [
                      _MenuRow(
                        title: 'Editar dados de perfil',
                        onTap: () => _notImplemented('Editar dados de perfil'),
                      ),
                      _MenuRow(
                        title: 'Sobre',
                        onTap: () {
                          Navigator.of(context).push<void>(
                            MaterialPageRoute<void>(
                              builder: (context) => const AboutScreen(),
                            ),
                          );
                        },
                      ),
                      _MenuRow(
                        title: 'Ajuda',
                        onTap: () => _notImplemented('Ajuda'),
                      ),
                      _MenuRow(
                        title: 'Sair',
                        titleColor: AppColors.erro,
                        onTap: _logOut,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_isLoggingOut)
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.textoPreto.withValues(alpha: 0.35),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primaria),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Transform.translate(
          offset: const Offset(-10, 0),
          child: IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            color: AppColors.textoPreto,
            onPressed: _goHome,
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
          ),
        ),
        Expanded(
          child: Text(
            'Configurações',
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textoPreto,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }

  Widget _buildProfile(String name, String email) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.branco,
            border: Border.all(color: AppColors.primaria, width: 1.5),
          ),
          child: const Icon(
            Icons.person,
            color: AppColors.primaria,
            size: 44,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaria,
          ),
        ),
        if (email.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textoSecundario,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMenuCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordaCampo),
        boxShadow: [
          BoxShadow(
            color: AppColors.sombraCard,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(height: 1, thickness: 1, color: AppColors.linhaDivisoria),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.title,
    required this.onTap,
    this.titleColor,
  });

  final String title;
  final VoidCallback onTap;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: titleColor ?? AppColors.textoPreto,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textoSecundario,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
