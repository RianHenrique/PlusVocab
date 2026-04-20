import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final introBodyStyle = GoogleFonts.lexend(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textoPreto,
      height: 1.5,
    );

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
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  Text(
                    '+Vocab: Seu vocabulário, do seu jeito.',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textoAzul,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      style: introBodyStyle,
                      children: [
                        const TextSpan(
                          text:
                              'O +Vocab utiliza Inteligência Artificial para transformar seus interesses e nível de inglês em práticas personalizadas. Desenvolvido como projeto de graduação no ',
                        ),
                        TextSpan(
                          text: 'IFCE — Campus Fortaleza',
                          style: introBodyStyle.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const TextSpan(
                          text:
                              ', o app foca em quem já tem base no idioma e quer expandir o domínio de palavras de forma contextualizada.',
                        ),
                      ],
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 28),
                  _FeatureCard(
                    emoji: '🤖',
                    title: 'IA Personalizada',
                    description:
                        'Exercícios gerados com base nos seus temas favoritos e nível atual.',
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    emoji: '🧠',
                    title: 'Repetição Espaçada',
                    description:
                        'Utilizamos o sistema de \'caixas de domínio\' para garantir que você não esqueça o que aprendeu.',
                  ),
                  const SizedBox(height: 12),
                  _FeatureCard(
                    emoji: '📈',
                    title: 'Progressão Inteligente',
                    description:
                        'Cada prática foca em 5 palavras que você está dominando e introduz 1 termo novo para manter o desafio equilibrado.',
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Desenvolvedores (Engenharia de Computação):',
                    textAlign: TextAlign.start,
                    style: GoogleFonts.lexend(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textoAzul,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _DeveloperProfile(
                          assetPath: 'assets/images/andre.png',
                          name: 'Francisco André',
                        ),
                      ),
                      Expanded(
                        child: _DeveloperProfile(
                          assetPath: 'assets/images/leticia.png',
                          name: 'Letícia Rodrigues',
                        ),
                      ),
                      Expanded(
                        child: _DeveloperProfile(
                          assetPath: 'assets/images/rian.png',
                          name: 'Rian Henrique',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
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
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
          ),
        ),
        Expanded(
          child: Center(
            child: Image.asset(
              'assets/images/PlusVocab2.png',
              height: 36,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.emoji,
    required this.title,
    required this.description,
  });

  final String emoji;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.lexend(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.textoAzul,
      height: 1.2,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.bordaCampo, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.sombraLeve,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 17, height: 1),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: titleStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.start,
            style: GoogleFonts.lexend(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.textoPreto,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeveloperProfile extends StatelessWidget {
  const _DeveloperProfile({
    required this.assetPath,
    required this.name,
  });

  final String assetPath;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: AppColors.fundoClaro,
            backgroundImage: AssetImage(assetPath),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textoPreto,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
