import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/features/temas/controllers/temas_controller.dart';
import 'package:plus_vocab/features/temas/components/seletor_modalidades.dart';
import 'package:plus_vocab/features/temas/components/seletor_dificuldade.dart';
import 'package:provider/provider.dart';

class CriarTemaScreen extends StatefulWidget {
  const CriarTemaScreen({super.key, required this.contexto});

  final String contexto;

  @override
  State<CriarTemaScreen> createState() => _CriarTemaScreenState();
}

class _CriarTemaScreenState extends State<CriarTemaScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  late TextEditingController _contextoController;
  final List<String> _selecionados = [];
  String _nivelFluencia = "Básico";

  final List<String> allOptions = [
    "Vocabulary Match",
    "Fill in the Blanks",
    "Dialogue Completion",
    "Listening Comprehension",
  ];

  // Mapeia o nome exibido para o nome esperado pela API
  static const _modalidadeMap = {
    "Vocabulary Match": "vocab_match",
    "Fill in the Blanks": "fill_blanks",
    "Dialogue Completion": "dialogue_completion",
    "Listening Comprehension": "listening",
  };

  @override
  void initState() {
    super.initState();
    _contextoController = TextEditingController(text: widget.contexto);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _contextoController.dispose();
    super.dispose();
  }

  bool _validarCampos() {
    if (_tituloController.text.trim().isEmpty) {
      _mostrarErro('Informe o título do tema.');
      return false;
    }
    if (_contextoController.text.trim().isEmpty) {
      _mostrarErro('Informe o contexto da prática.');
      return false;
    }
    if (_selecionados.isEmpty) {
      _mostrarErro('Selecione ao menos uma modalidade.');
      return false;
    }
    return true;
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), backgroundColor: AppColors.erro),
    );
  }

  Future<void> _criarEIniciar() async {
    if (!_validarCampos()) return;

    final controller = context.read<TemasController>();
    final modalidades = _selecionados.map((m) => _modalidadeMap[m]!).toList();

    final pratica = await controller.criarTemaEIniciarPratica(
      nome: _tituloController.text.trim(),
      descricao: _contextoController.text.trim(),
      modalidades: modalidades,
    );

    if (!mounted) return;

    if (pratica != null) {
      // TODO: navegar para a tela de exercícios passando pratica
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prática iniciada!'), backgroundColor: AppColors.acerto),
      );
    } else {
      _mostrarErro(controller.errorMessage ?? 'Erro ao criar tema.');
    }
  }

  Future<void> _apenascriarTema() async {
    if (!_validarCampos()) return;

    final controller = context.read<TemasController>();
    final modalidades = _selecionados.map((m) => _modalidadeMap[m]!).toList();

    final themeId = await controller.criarTema(
      nome: _tituloController.text.trim(),
      descricao: _contextoController.text.trim(),
      modalidades: modalidades,
    );

    if (!mounted) return;

    if (themeId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tema criado com sucesso!'), backgroundColor: AppColors.acerto),
      );
      Navigator.of(context).pop();
    } else {
      _mostrarErro(controller.errorMessage ?? 'Erro ao criar tema.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<TemasController>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.fundoClaro,
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              "assets/images/background.png",
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(.25),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text("Criar um tema", style: GoogleFonts.lexend(color: AppColors.textoPreto, fontSize: 16)),
                centerTitle: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: AppColors.textoPreto, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Configurações do tema",
                          style: GoogleFonts.lexend(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: AppColors.textoAzul,
                          ),
                        ),
                        const Divider(color: AppColors.primaria),
                        const SizedBox(height: 10),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Título", style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoPreto)),
                              const SizedBox(height: 8),
                              _buildCampo(controller: _tituloController),
                              const SizedBox(height: 16),
                              Text("Contexto da prática", style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoPreto)),
                              const SizedBox(height: 8),
                              _buildCampo(controller: _contextoController, maxLines: 3),
                              const SizedBox(height: 28),
                              Text("Modalidades da prática", style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoPreto)),
                              const SizedBox(height: 8),
                              SelectionListGroup(
                                options: allOptions,
                                selectedOptions: _selecionados,
                                onOptionToggled: (option) {
                                  setState(() {
                                    if (_selecionados.contains(option)) {
                                      _selecionados.remove(option);
                                    } else {
                                      _selecionados.add(option);
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              Text("Dificuldade", style: GoogleFonts.lexend(fontSize: 12, color: AppColors.textoPreto)),
                              const SizedBox(height: 8),
                              SeletorDificuldade(
                                options: const ["Básico", "Intermediário", "Avançado"],
                                selectedOption: _nivelFluencia,
                                onOptionChange: (novoValor) {
                                  setState(() => _nivelFluencia = novoValor);
                                },
                              ),
                              const SizedBox(height: 40),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaria,
                                    foregroundColor: AppColors.branco,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: isLoading ? null : _criarEIniciar,
                                  child: isLoading
                                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : Text("Criar e iniciar partida", style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.branco)),
                                ),
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: isLoading ? null : _apenascriarTema,
                                  child: Text("Apenas criar o tema", style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.primaria)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampo({required TextEditingController controller, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fundoClaro,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.bordaCampo, width: 1),
        boxShadow: [BoxShadow(color: AppColors.sombraLeve, blurRadius: 4, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: GoogleFonts.lexend(fontSize: 14, color: AppColors.textoPreto),
        decoration: const InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.fundoClaro,
        ),
      ),
    );
  }
}
