import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/pratica/exercicio/views/practice_session_loading_screen.dart';
import 'package:plus_vocab/features/temas/controllers/temas_controller.dart';
import 'package:plus_vocab/features/temas/models/tema_resumo.dart';
import 'package:plus_vocab/features/temas/views/criar_tema_screen.dart';
import 'package:provider/provider.dart';

class TemasScreen extends StatefulWidget {
  const TemasScreen({super.key});

  @override
  State<TemasScreen> createState() => _TemasScreenState();
}

class _TemasScreenState extends State<TemasScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _ordenacao = 'alfabética';

  static const _opcoesOrdenacao = ['alfabética', 'mais recentes', 'mais antigas'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TemasController>().carregarTemasNaPrimeiraAberturaDestaTela();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TemaResumo> _filtrarEOrdenar(List<TemaResumo> temas) {
    var lista = temas.toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      lista = lista.where((t) => t.name.toLowerCase().contains(q) || t.description.toLowerCase().contains(q)).toList();
    }

    if (_ordenacao == 'alfabética') {
      lista.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_ordenacao == 'mais recentes') {
      lista.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_ordenacao == 'mais antigas') {
      lista.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return lista;
  }

  void _abrirDetalhes(BuildContext context, TemaResumo tema) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TemaBottomSheet(tema: tema),
    );
  }

  Future<void> _abrirEdicao(BuildContext context, TemaResumo tema) async {
    final atualizado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CriarTemaScreen(contexto: tema.description, temaParaEditar: tema),
      ),
    );
    if (atualizado == true && context.mounted) {
      context.read<TemasController>().forcarAtualizacaoListaTemas();
    }
  }

  Future<void> _confirmarDelecao(BuildContext context, TemaResumo tema) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Excluir tema', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
        content: Text(
          'Tem certeza que deseja excluir "${tema.name}"? Esta ação não pode ser desfeita.',
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
            child: Text('Excluir', style: GoogleFonts.lexend()),
          ),
        ],
      ),
    );

    if (confirmar == true && context.mounted) {
      final ok = await context.read<TemasController>().deletarTema(tema.id);
      if (!context.mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<TemasController>().errorMessage ?? 'Erro ao excluir tema.'),
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
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const CriarTemaScreen(contexto: ''),
            ),
          );
          if (context.mounted) {
            context.read<TemasController>().forcarAtualizacaoListaTemas();
          }
        },
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
                  child: Consumer<TemasController>(
                    builder: (context, controller, _) {
                      if (controller.isLoadingListaTemas && !controller.temasListaJaCarregada) {
                        return const Center(child: CircularProgressIndicator(color: AppColors.primaria));
                      }

                      if (controller.errorListaTemas != null && !controller.temasListaJaCarregada) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                controller.errorListaTemas!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario),
                              ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: () => controller.forcarAtualizacaoListaTemas(),
                                style: FilledButton.styleFrom(backgroundColor: AppColors.primaria),
                                child: Text('Tentar novamente', style: GoogleFonts.lexend(fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        );
                      }

                      final filtrados = _filtrarEOrdenar(controller.temasEmMemoria);

                      if (controller.temasEmMemoria.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Nenhum tema cadastrado ainda.\nCrie seu primeiro tema!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario, height: 1.5),
                            ),
                          ),
                        );
                      }

                      if (filtrados.isEmpty) {
                        return Center(
                          child: Text(
                            'Nenhum tema encontrado.',
                            style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario),
                          ),
                        );
                      }

                      return RefreshIndicator(
                        color: AppColors.primaria,
                        onRefresh: () => controller.forcarAtualizacaoListaTemas(),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                          itemCount: filtrados.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final tema = filtrados[index];
                            return _TemaCard(
                              tema: tema,
                              onTapCard: () => _abrirDetalhes(context, tema),
                              onEditar: () => _abrirEdicao(context, tema),
                              onDeletar: () => _confirmarDelecao(context, tema),
                              onIniciar: () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => PracticeSessionLoadingScreen(
                                    themeId: tema.id,
                                    practiceTitle: tema.name,
                                  ),
                                ),
                              ),
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
            'Seus temas',
            style: GoogleFonts.lexend(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textoAzul,
            ),
          ),
        ],
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
            child: _DropdownFiltro<String>(
              value: _ordenacao,
              items: _opcoesOrdenacao,
              labelBuilder: (v) => v,
              onChanged: (v) {
                if (v != null) {
                  setState(() => _ordenacao = v);
                }
              },
            ),
          ),
          const Spacer(),
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
                  hintText: 'Buscar tema...',
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
}

class _DropdownFiltro<T> extends StatelessWidget {
  const _DropdownFiltro({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final void Function(T?) onChanged;

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
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textoSecundario),
          style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoPreto),
          items: items.map((item) => DropdownMenuItem<T>(
            value: item,
            child: Text(
              labelBuilder(item),
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoPreto),
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TemaCard extends StatelessWidget {
  const _TemaCard({
    required this.tema,
    required this.onTapCard,
    required this.onEditar,
    required this.onDeletar,
    required this.onIniciar,
  });

  final TemaResumo tema;
  final VoidCallback onTapCard;
  final VoidCallback onEditar;
  final VoidCallback onDeletar;
  final VoidCallback onIniciar;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapCard,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: AppColors.branco,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bordaCampo),
          boxShadow: [BoxShadow(color: AppColors.sombraCard, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Conteúdo superior ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          tema.name,
                          maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primaria),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ActionIcon(icon: Icons.edit_outlined, color: AppColors.primaria, onTap: onEditar),
                      const SizedBox(width: 4),
                      _ActionIcon(icon: Icons.delete_outline, color: AppColors.erro, onTap: onDeletar),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Indicadores mocados
                  Row(
                    children: [
                      Text('2 dias atrás', style: GoogleFonts.lexend(fontSize: 11, color: AppColors.textoSecundario)),
                      _bullet(),
                      Text('0 partidas', style: GoogleFonts.lexend(fontSize: 11, color: AppColors.textoSecundario)),
                      _bullet(),
                      Text('0% de acerto', style: GoogleFonts.lexend(fontSize: 11, color: AppColors.textoSecundario)),
                    ],
                  ),
                ],
              ),
            ),
            // --- Faixa "Iniciar" ---
            GestureDetector(
              onTap: onIniciar,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: AppColors.primaria,
                child: Text(
                  'Iniciar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lexend(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.branco),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bullet() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: Text('•', style: TextStyle(fontSize: 10, color: AppColors.textoSecundario)),
  );
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.color, required this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}


class _TemaBottomSheet extends StatelessWidget {
  const _TemaBottomSheet({required this.tema});

  final TemaResumo tema;

  static const _labels = {
    'vocab_match': 'Vocabulary Match',
    'fill_blanks': 'Fill in the Blanks',
    'dialogue_completion': 'Dialogue Completion',
    'listening': 'Listening Comprehension',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.branco,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.bordaCampo,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            tema.name,
            style: GoogleFonts.lexend(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textoPreto),
          ),
          if (tema.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              tema.description,
              style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoSecundario, height: 1.5),
            ),
          ],
          if (tema.modalities.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Modalidades', style: GoogleFonts.lexend(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textoPreto)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: tema.modalities.map((m) {
                final label = _labels[m.name] ?? m.name;
                return Chip(
                  label: Text(label, style: GoogleFonts.lexend(fontSize: 12, color: AppColors.primaria)),
                  backgroundColor: AppColors.primaria.withOpacity(0.1),
                  side: BorderSide(color: AppColors.primaria.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PracticeSessionLoadingScreen(
                      themeId: tema.id,
                      practiceTitle: tema.name,
                    ),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaria,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('Iniciar prática', style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
