import "package:flutter/material.dart";
import 'package:google_fonts/google_fonts.dart';
import 'package:plus_vocab/components/profile_circle.dart';
import 'package:plus_vocab/features/homePage/components/calendario_horizontal.dart';
import 'package:plus_vocab/features/homePage/components/tab_selector.dart';
import 'package:plus_vocab/features/homePage/views/temas_screen.dart';
import 'package:plus_vocab/features/pratica/views/criar_pratica_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Color _blue = const Color(0xFF2563EB);
  final Color _bgLight = const Color(0xFFf3f4f6);

  String _currentTab = 'Temas';

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
                          color: _blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
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
                        ]
                      ),
                      child: TextField(
                        onSubmitted: (value){
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  FormsPratica(contexto: value),
                            ),
                          );
                        },
                        textInputAction: TextInputAction.send, // Garante o ícone de 'retorno'
                        textAlignVertical: TextAlignVertical.center,
                        maxLines: null,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: "Digite o contexto da prática",
                          hintStyle: GoogleFonts.lexend(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.mic, color: _blue),
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
