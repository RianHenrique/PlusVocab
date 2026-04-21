import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/dicionario/models/palavra_info_model.dart';
import 'package:plus_vocab/features/dicionario/models/palavra_info_service.dart';

Future<void> mostrarPalavraInfoModal(BuildContext context, String word) {
  return showDialog(
    context: context,
    builder: (_) => _PalavraInfoModal(word: word),
  );
}

class _PalavraInfoModal extends StatefulWidget {
  const _PalavraInfoModal({required this.word});
  final String word;

  @override
  State<_PalavraInfoModal> createState() => _PalavraInfoModalState();
}

class _PalavraInfoModalState extends State<_PalavraInfoModal> {
  final _service = PalavraInfoService();
  late final FlutterTts _tts;
  bool _speaking = false;

  PalavraInfo? _info;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
    _carregar();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _carregar() async {
    try {
      final info = await _service.buscarInfo(widget.word);
      if (mounted) setState(() { _info = info; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _falar(String text) async {
    if (_speaking) {
      await _tts.stop();
      setState(() => _speaking = false);
    } else {
      setState(() => _speaking = true);
      await _tts.speak(text);
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _traduzirPartOfSpeech(String pos) {
    const map = {
      'noun': 'substantivo',
      'verb': 'verbo',
      'adjective': 'adjetivo',
      'adverb': 'advérbio',
      'pronoun': 'pronome',
      'preposition': 'preposição',
      'conjunction': 'conjunção',
      'interjection': 'interjeição',
    };
    return map[pos] ?? pos;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.branco,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Informações da palavra',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaria),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(Icons.close, size: 20, color: AppColors.textoSecundario),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_loading)
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(color: AppColors.primaria),
                ))
              else if (_error != null || _info == null)
                Center(child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text('Não foi possível carregar as informações.', textAlign: TextAlign.center, style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoSecundario)),
                ))
              else
                _buildConteudo(_info!),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConteudo(PalavraInfo info) {
    final pos = info.partOfSpeech;
    final posLabel = pos.isNotEmpty ? '$pos | ${_traduzirPartOfSpeech(pos)}' : '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tipo da palavra
        if (posLabel.isNotEmpty) ...[
          Center(
            child: Text(posLabel, style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoSecundario)),
          ),
          const SizedBox(height: 10),
        ],

        // Palavra + botão TTS
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _capitalize(info.word),
                style: GoogleFonts.lexend(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textoPreto),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _falar(info.word),
                child: Icon(
                  _speaking ? Icons.volume_up : Icons.volume_up_outlined,
                  size: 22,
                  color: AppColors.primaria,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tradução
        Text('Tradução', style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoPreto)),
        const SizedBox(height: 4),
        Text(
          _capitalize(info.traducao),
          style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaria),
        ),
        const SizedBox(height: 14),

        // Definição
        if (info.definicao.isNotEmpty) ...[
          Text('Definição', style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoPreto)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.bordaCampo),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(info.definicao, style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoPreto, height: 1.4)),
          ),
        ],

        // Exemplos
        if (info.exemplos.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('Exemplos de uso:', style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoPreto)),
          const SizedBox(height: 8),
          ...info.exemplos.asMap().entries.map((entry) {
            final i = entry.key + 1;
            final exemplo = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$i. ', style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoPreto)),
                  Expanded(child: _buildExemploRichText(exemplo, info.word)),
                  GestureDetector(
                    onTap: () => _falar(exemplo),
                    child: const Padding(
                      padding: EdgeInsets.only(left: 6, top: 1),
                      child: Icon(Icons.volume_up_outlined, size: 16, color: AppColors.primaria),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildExemploRichText(String exemplo, String word) {
    final lower = exemplo.toLowerCase();
    final wordLower = word.toLowerCase();
    final idx = lower.indexOf(wordLower);

    if (idx == -1) {
      return Text(exemplo, style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoPreto));
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoPreto),
        children: [
          TextSpan(text: exemplo.substring(0, idx)),
          TextSpan(
            text: exemplo.substring(idx, idx + word.length),
            style: GoogleFonts.lexend(fontSize: 13, color: AppColors.primaria, fontWeight: FontWeight.w600),
          ),
          TextSpan(text: exemplo.substring(idx + word.length)),
        ],
      ),
    );
  }
}
