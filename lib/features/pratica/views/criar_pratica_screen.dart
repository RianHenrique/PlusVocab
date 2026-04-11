import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';

import 'package:plus_vocab/features/pratica/components/seletor_modalidades.dart';
import 'package:plus_vocab/features/pratica/components/seletor_dificuldade.dart';

class FormsPratica extends StatefulWidget {
  const FormsPratica({super.key, required this.contexto});

  final String contexto;

  @override
  State<FormsPratica> createState() => _FormsPraticaState();
}

class _FormsPraticaState extends State<FormsPratica> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _contextoController;
  final List<String> _selecionados = [];
  String _nivelFluencia = "Básico"; // TODO: vai vir do backend

  final List<String> allOptions = [
    "Vocabulary Match",
    "Fill in the Blanks",
    "Dialogue Completion",
    "Listening Comprehension",
  ];

  @override
  void initState() {
    super.initState();
    _contextoController = TextEditingController(text: widget.contexto);
  }

  @override
  void dispose() {
    // 3. Importante: Limpe o controller para evitar vazamento de memória
    _contextoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                title: Text("Criar uma prática", style: GoogleFonts.lexend(color: AppColors.textoPreto, fontSize: 16),),
                centerTitle: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: AppColors.textoPreto, size: 20,),
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
                          "Configurações de prática",
                          style: GoogleFonts.lexend(
                            fontSize: 14, 
                            fontWeight: FontWeight.normal, 
                            color: AppColors.textoAzul
                          ),
                        ),
                        const Divider(color: AppColors.primaria),
                        const SizedBox(height: 10),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Contexto da prática",
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: AppColors.textoPreto,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.fundoClaro,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.bordaCampo,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.sombraLeve,
                                      blurRadius: 4,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _contextoController,
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: AppColors.textoPreto,
                                  ),
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: AppColors.fundoClaro,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                "Modalidades de prática",
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: AppColors.textoPreto,
                                ),
                              ),
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
                              Text(
                                "Nível de fluência",
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: AppColors.textoPreto,
                                ),
                              ),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    "Iniciar uma partida",
                                    style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.branco),
                                  )
                                ),
                              ),
                              const SizedBox(height: 5),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    "Criar a prática",
                                    style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.primaria),
                                  )
                                ),
                              ),
                            ],
                          )
                        )
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
}