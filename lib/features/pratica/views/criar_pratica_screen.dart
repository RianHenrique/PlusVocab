import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  List<String> _selecionados = [];
  String _nivelFluencia = "Básico"; // TODO: vai vir do backend

  final List<String> allOptions = [
    "Vocabulary Match",
    "Fill in the Blanks",
    "Dialogue Completion",
    "Listening Comprehension",
  ];

  final Color _blue = const Color(0xFF2563EB);
  final Color _bgLight = const Color(0xFFf3f4f6);

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
      backgroundColor: _bgLight,
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
                title: Text("Criar uma prática", style: GoogleFonts.lexend(color: Colors.black, fontSize: 16),),
                centerTitle: true,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20,),
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
                            color: _blue
                          ),
                        ),
                        Divider(color: _blue),
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
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: _bgLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFFD9D9D9),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _contextoController,
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  decoration: InputDecoration(
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                      borderSide: BorderSide.none, // Remove a linha da borda padrão
                                    ),
                                    filled: true,
                                    fillColor: _bgLight,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                "Modalidades de prática",
                                style: GoogleFonts.lexend(
                                  fontSize: 12,
                                  color: Colors.black87,
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
                                  color: Colors.black87,
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
                                    backgroundColor: _blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: Text(
                                    "Iniciar uma partida",
                                    style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.bold, color: _bgLight),
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
                                    style: GoogleFonts.lexend(fontSize: 14, fontWeight: FontWeight.normal, color: _blue),
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