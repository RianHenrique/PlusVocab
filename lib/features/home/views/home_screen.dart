import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/core/theme/app_colors.dart';
import 'package:plus_vocab/components/profile_circle.dart';
import 'package:plus_vocab/features/home/components/calendario_horizontal.dart';
import 'package:plus_vocab/features/home/components/tab_selector.dart';
import 'package:plus_vocab/features/home/views/temas_screen.dart';
import 'package:plus_vocab/features/temas/views/criar_tema_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _currentTab = 'Temas';

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
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            "assets/images/PlusVocab2.png",
                            height: 35,
                          ),
                        ),
                        const ProfileCircle(),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const HorizontalCalendar(),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "O que vamos aprender hoje?",
                        style: GoogleFonts.lexend(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textoAzul,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
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
                        ]
                      ),
                      child: TextField(
                        onSubmitted: (value){
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  CriarTemaScreen(contexto: value),
                            ),
                          );
                        },
                        textInputAction: TextInputAction.send, // Garante o ícone de 'retorno'
                        textAlignVertical: TextAlignVertical.center,
                        maxLines: null,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: AppColors.textoPreto,
                        ),
                        decoration: InputDecoration(
                          hintText: "Digite o contexto da prática",
                          hintStyle: GoogleFonts.lexend(
                            fontSize: 14,
                            color: AppColors.textoSecundario,
                          ),
                          border: InputBorder.none,
                          suffixIcon: const Icon(Icons.mic, color: AppColors.primaria),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    TabSelector(
                      selectedTab: _currentTab,
                      onTabChanged: (newTab) {
                        setState(() {
                          _currentTab = newTab; // O pai atualiza e redesenha tudo!
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _currentTab == 'Temas' 
                        ? const TemasScreen() 
                        : (_currentTab == 'Palavras' ? const Text("Palavras") : const Text("Progresso")),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
