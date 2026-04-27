import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  static const String _supportEmail = 'plusvocab@gmail.com';

  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _emailBodyController = TextEditingController();

  final List<_FrequentlyAskedQuestion> _frequentlyAskedQuestions =
      const <_FrequentlyAskedQuestion>[
        _FrequentlyAskedQuestion(
          question: 'Como adicionar uma nova palavra?',
          answer:
              'Você pode adicionar novas palavras nos exercícios e na tela de dicionário pessoal. '
              'Basta selecionar a palavra e confirmar o salvamento.',
        ),
        _FrequentlyAskedQuestion(
          question: 'Quais são as modalidades de exercício e como funcionam?',
          answer:
              'O +Vocab oferece modalidades como completar diálogos, preencher lacunas, compreensão '
              'auditiva e associação de vocabulário. Cada prática é personalizada para o seu nível e dificuldades.',
        ),
        _FrequentlyAskedQuestion(
          question: 'Posso criar um tema sem iniciá-lo imediatamente?',
          answer:
              'Sim. Você pode criar temas e deixá-los prontos para iniciar depois, quando quiser '
              'fazer uma nova prática.',
        ),
      ];

  @override
  void dispose() {
    _topicController.dispose();
    _emailBodyController.dispose();
    super.dispose();
  }

  Future<void> _sendTopicSuggestion() async {
    final String topic = _topicController.text.trim();
    final String subject =
        topic.isEmpty ? 'Sugestão de tópico' : 'Sugestão de tópico: $topic';

    await _launchEmail(subject: subject, body: '');
  }

  Future<void> _sendSupportEmail() async {
    final String emailBody = _emailBodyController.text.trim();
    await _launchEmail(
      subject: 'Contato pelo app +Vocab',
      body: emailBody,
    );
  }

  Future<void> _launchEmail({
    required String subject,
    required String body,
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: <String, String>{
        'subject': subject,
        'body': body,
      },
    );

    try {
      final bool opened = await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o aplicativo de e-mail.'),
          ),
        );
      }
    } on MissingPluginException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Integração de e-mail indisponível. Reinicie o app por completo.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o aplicativo de e-mail.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      body: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation<double>(0.25),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildHeader(context),
                  const SizedBox(height: 22),
                  Text(
                    'FAQ (Perguntas Frequentes):',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textoPreto,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._frequentlyAskedQuestions.map(
                    (_FrequentlyAskedQuestion question) =>
                        _FrequentlyAskedQuestionTile(question: question),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Não encontrou o que procura? Sugira um tópico',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textoPreto,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInputCard(
                    child: TextField(
                      controller: _topicController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendTopicSuggestion(),
                      style: GoogleFonts.lexend(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textoPreto,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Insira o tópico que procura',
                        hintStyle: GoogleFonts.lexend(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textoHint,
                        ),
                        suffixIcon: IconButton(
                          onPressed: _sendTopicSuggestion,
                          icon: const Icon(
                            Icons.send,
                            color: AppColors.primaria,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Ainda precisa de ajuda? Nos envie um email',
                    style: GoogleFonts.lexend(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textoPreto,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInputCard(
                    child: TextField(
                      controller: _emailBodyController,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      minLines: 4,
                      maxLines: 6,
                      style: GoogleFonts.lexend(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textoPreto,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Escreva o email aqui...',
                        hintStyle: GoogleFonts.lexend(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textoHint,
                        ),
                        suffixIcon: Align(
                          widthFactor: 1,
                          heightFactor: 1,
                          alignment: Alignment.bottomCenter,
                          child: IconButton(
                            onPressed: _sendSupportEmail,
                            icon: const Icon(
                              Icons.send,
                              color: AppColors.primaria,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
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
      children: <Widget>[
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

  Widget _buildInputCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.bordaCampo),
      ),
      child: child,
    );
  }
}

class _FrequentlyAskedQuestionTile extends StatelessWidget {
  const _FrequentlyAskedQuestionTile({required this.question});

  final _FrequentlyAskedQuestion question;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.bordaCampo),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: AppColors.textoPreto,
          collapsedIconColor: AppColors.textoPreto,
          title: Text(
            question.question,
            style: GoogleFonts.lexend(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.textoPreto,
            ),
          ),
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                question.answer,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textoSecundario,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrequentlyAskedQuestion {
  const _FrequentlyAskedQuestion({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}
