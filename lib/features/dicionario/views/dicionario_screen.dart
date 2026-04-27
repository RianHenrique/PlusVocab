import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/dicionario/controllers/dicionario_controller.dart';
import 'package:plus_vocab/features/dicionario/models/palavra_model.dart';
import 'package:provider/provider.dart';
import 'palavra_info_modal.dart';

class DicionarioScreen extends StatefulWidget {
  const DicionarioScreen({super.key});

  @override
  State<DicionarioScreen> createState() => _DicionarioScreenState();
}

class _DicionarioScreenState extends State<DicionarioScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _ordenacao = 'alfabética';

  static const _opcoesOrdenacao = ['alfabética', 'mais recentes', 'maior nível', 'menor nível'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DicionarioController>().carregarSeNecessario();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PalavraModel> _filtrarEOrdenar(List<PalavraModel> palavras) {
    var lista = palavras.toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      lista = lista.where((p) => p.word.text.toLowerCase().contains(q)).toList();
    }

    switch (_ordenacao) {
      case 'alfabética':
        lista.sort((a, b) => a.word.text.toLowerCase().compareTo(b.word.text.toLowerCase()));
      case 'mais recentes':
        lista.sort((a, b) => (b.lastSeenAt ?? '').compareTo(a.lastSeenAt ?? ''));
      case 'maior nível':
        lista.sort((a, b) => b.boxLevel.compareTo(a.boxLevel));
      case 'menor nível':
        lista.sort((a, b) => a.boxLevel.compareTo(b.boxLevel));
    }

    return lista;
  }

  void _abrirAdicionarPalavra() {
    showDialog(
      context: context,
      builder: (ctx) => _AdicionarPalavraDialog(
        onAdicionar: (word) => context.read<DicionarioController>().adicionarPalavra(word),
        errorMessage: () => context.read<DicionarioController>().errorMessage,
        foiReativada: () => context.read<DicionarioController>().ultimaReativada,
      ),
    );
  }

  Future<void> _confirmarRemocao(BuildContext context, PalavraModel palavra) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remover palavra', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
        content: Text(
          'Tem certeza que deseja remover "${palavra.word.text}" do seu dicionário?',
          style: GoogleFonts.lexend(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancelar', style: GoogleFonts.lexend(color: AppColors.textoSecundario)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.erro),
            child: Text('Remover', style: GoogleFonts.lexend()),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      final ok = await context.read<DicionarioController>().removerPalavra(palavra.id);
      if (!context.mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<DicionarioController>().errorMessage ?? 'Erro ao remover.'),
            backgroundColor: AppColors.erro,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.branco,
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirAdicionarPalavra,
        backgroundColor: AppColors.textoAzul,
        child: const Icon(Icons.add, color: AppColors.branco),
      ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                _buildSearchBar(),
                _buildFiltros(),
                const SizedBox(height: 4),
                Expanded(
                  child: Consumer<DicionarioController>(
                    builder: (context, controller, _) {
                      if (controller.isLoadingLista && !controller.listaJaCarregada) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primaria));
                      }

                      if (controller.errorLista != null && !controller.listaJaCarregada) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.errorLista!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () => controller.forcarAtualizacao(),
                                style: FilledButton.styleFrom(backgroundColor: AppColors.primaria),
                                child: Text('Tentar novamente', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      }

                      final filtradas = _filtrarEOrdenar(controller.palavras);

                      if (controller.palavras.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Seu dicionário está vazio.\nAdicione sua primeira palavra!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario, height: 1.5),
                            ),
                          ),
                        );
                      }

                      if (filtradas.isEmpty) {
                        return Center(
                          child: Text(
                            'Nenhuma palavra encontrada.',
                            style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.primaria,
                        onRefresh: () => controller.forcarAtualizacao(),
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            mainAxisExtent: 80,
                          ),
                          itemCount: filtradas.length,
                          itemBuilder: (context, index) {
                            final palavra = filtradas[index];
                            return _PalavraCard(
                              palavra: palavra,
                              onTap: () => mostrarPalavraInfoModal(context, palavra.word.text),
                              onRemover: () => _confirmarRemocao(context, palavra),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 28),
            color: AppColors.textoPreto,
            onPressed: () => Navigator.of(context).maybePop(),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(height: 8),
          Text(
            'Seu dicionário',
            style: GoogleFonts.lexend(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textoAzul),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.branco,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.bordaCampo),
          boxShadow: [BoxShadow(color: AppColors.sombraLeve, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 20, color: AppColors.textoSecundario),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                textAlignVertical: TextAlignVertical.center,
                style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoPreto),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Buscar palavra...',
                  hintStyle: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoSecundario),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          Text('Ordenar', style: GoogleFonts.lexend(fontSize: 11, color: AppColors.textoSecundario)),
          const SizedBox(width: 8),
          Expanded(
            child: _DicionarioDropdown(
              value: _ordenacao,
              items: _opcoesOrdenacao,
              onChanged: (v) { if (v != null) setState(() => _ordenacao = v); },
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _DicionarioDropdown extends StatelessWidget {
  const _DicionarioDropdown({required this.value, required this.items, required this.onChanged});

  final String value;
  final List<String> items;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.bordaCampo),
        boxShadow: [BoxShadow(color: AppColors.sombraLeve, blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textoSecundario),
          style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoPreto),
          items: items.map((item) => DropdownMenuItem<String>(
            value: item,
            child: Text(item, overflow: TextOverflow.ellipsis, style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoPreto)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PalavraCard extends StatelessWidget {
  const _PalavraCard({required this.palavra, required this.onTap, required this.onRemover});

  final PalavraModel palavra;
  final VoidCallback onTap;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    final partidas = palavra.correctCount + palavra.incorrectCount;
    final pctAcerto = partidas > 0 ? (palavra.correctCount / partidas * 100).round() : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      decoration: BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bordaCampo),
        boxShadow: [BoxShadow(color: AppColors.sombraCard, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stats
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text('$partidas partidas', style: GoogleFonts.lexend(fontSize: 10, color: AppColors.textoSecundario)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text('•', style: TextStyle(fontSize: 10, color: AppColors.textoSecundario)),
                ),
                Text('$pctAcerto% de acerto', style: GoogleFonts.lexend(fontSize: 10, color: AppColors.textoSecundario)),
              ],
            ),
          ),
          const SizedBox(height: 5),
          // Ícone deletar + palavra
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  palavra.word.text.isEmpty ? '' : palavra.word.text[0].toUpperCase() + palavra.word.text.substring(1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primaria),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRemover,
                child: Icon(Icons.delete_outline, size: 18, color: AppColors.erro),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}

class _AdicionarPalavraDialog extends StatefulWidget {
  const _AdicionarPalavraDialog({required this.onAdicionar, required this.errorMessage, required this.foiReativada});

  final Future<bool> Function(String) onAdicionar;
  final String? Function() errorMessage;
  final bool Function() foiReativada;

  @override
  State<_AdicionarPalavraDialog> createState() => _AdicionarPalavraDialogState();
}

class _AdicionarPalavraDialogState extends State<_AdicionarPalavraDialog> {
  final _controller = TextEditingController();
  bool _loading = false;
  bool _sucesso = false;
  bool _reativada = false;
  String? _erro;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final word = _controller.text.trim();
    if (word.isEmpty || _loading) return;
    setState(() { _loading = true; _sucesso = false; _erro = null; });
    final ok = await widget.onAdicionar(word);
    if (!mounted) return;
    if (ok) {
      _controller.clear();
      setState(() { _loading = false; _sucesso = true; _reativada = widget.foiReativada(); });
    } else {
      final msg = widget.errorMessage() ?? '';
      final erro = msg.toLowerCase().contains('não encontrada') || msg.toLowerCase().contains('not found')
          ? 'Opss!! Palavra não encontrada!'
          : msg.isNotEmpty ? msg : 'Erro ao adicionar.';
      setState(() { _loading = false; _erro = erro; });
    }
  }

  @override
  Widget build(BuildContext context) {
    String? mensagem;
    Color corMensagem = AppColors.acerto;
    if (_sucesso) {
      mensagem = _reativada ? 'Essa palavra já está no seu dicionário!' : 'Adicionada com sucesso!';
    } else if (_erro != null) {
      mensagem = _erro!;
      corMensagem = AppColors.erro;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(color: AppColors.branco),
            ),
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                opacity: const AlwaysStoppedAnimation(0.30),
              ),
            ),
            Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Spacer(),
                Text(
                  'Adição de novas palavras',
                  style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textoAzul),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 20, color: AppColors.textoAzul),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Campo de texto
            Container(
              decoration: BoxDecoration(
                color: AppColors.fundoClaro,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.bordaCampo),
              ),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _enviar(),
                style: GoogleFonts.lexend(fontSize: 13, color: AppColors.textoPreto),
                decoration: InputDecoration(
                  hintText: 'Digite a palavra em inglês...',
                  hintStyle: GoogleFonts.lexend(fontSize: 11, color: AppColors.textoSecundario),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  suffixIcon: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaria)),
                        )
                      : GestureDetector(
                          onTap: _enviar,
                          child: const Icon(Icons.send, size: 18, color: AppColors.primaria),
                        ),
                ),
              ),
            ),

            // Área fixa da mensagem — sempre ocupa espaço, evita resize do modal
            const SizedBox(height: 8),
            SizedBox(
              height: 20,
              child: mensagem != null
                  ? Text(
                      mensagem,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(fontSize: 11, color: corMensagem, fontWeight: FontWeight.w600),
                    )
                  : null,
            ),
          ],
        ),
      ),
          ],
        ),
      ),
    );
  }
}
