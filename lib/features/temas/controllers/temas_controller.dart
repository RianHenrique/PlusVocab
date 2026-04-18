import 'package:flutter/foundation.dart';
import '../models/temas_service.dart';

class TemasController extends ChangeNotifier {
  final TemasService _temasService;
  TemasController(this._temasService);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Apenas cria o tema e retorna o id
  Future<String?> criarTema({
    required String nome,
    required String descricao,
    required List<String> modalidades,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tema = await _temasService.criarTema(
        nome: nome,
        descricao: descricao,
        modalidades: modalidades,
      );
      return tema['id'] as String;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cria o tema e já inicia a prática
  Future<Map<String, dynamic>?> criarTemaEIniciarPratica({
    required String nome,
    required String descricao,
    required List<String> modalidades,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tema = await _temasService.criarTema(
        nome: nome,
        descricao: descricao,
        modalidades: modalidades,
      );

      final pratica = await _temasService.iniciarPratica(
        themeId: tema['id'] as String,
      );

      return pratica;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
