import 'package:flutter/foundation.dart';
import 'package:plus_vocab/features/pratica/exercicio/data/vocab_practice_service.dart';
import 'package:plus_vocab/features/pratica/exercicio/models/practice_session_models.dart';
import '../models/tema_resumo.dart';
import '../models/temas_service.dart';

class TemasController extends ChangeNotifier {
  final TemasService _temasService;
  final VocabPracticeService _vocabPracticeService;
  TemasController(this._temasService, this._vocabPracticeService);

  bool _isLoading = false;
  String? _errorMessage;

  bool _isLoadingListaTemas = false;
  String? _errorListaTemas;
  List<TemaResumo>? _temasEmMemoria;
  bool _jaSincronizouListaNaTelaDeTemas = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isLoadingListaTemas => _isLoadingListaTemas;
  String? get errorListaTemas => _errorListaTemas;

  List<TemaResumo> get temasEmMemoria =>
      List<TemaResumo>.unmodifiable(_temasEmMemoria ?? const []);

  bool get temasListaJaCarregada => _temasEmMemoria != null;

  void invalidarListaTemasEmMemoria() {
    _temasEmMemoria = null;
    _errorListaTemas = null;
    notifyListeners();
  }

  /// Na primeira entrada na tela de temas, sempre consulta a API (mesmo que o login já tenha trazido uma lista).
  Future<void> carregarTemasNaPrimeiraAberturaDestaTela() async {
    if (!_jaSincronizouListaNaTelaDeTemas) {
      _jaSincronizouListaNaTelaDeTemas = true;
      await forcarAtualizacaoListaTemas();
      return;
    }
    await carregarListaTemasSeNecessario();
  }

  Future<void> carregarListaTemasSeNecessario() async {
    if (_temasEmMemoria != null) return;
    await forcarAtualizacaoListaTemas();
  }

  Future<void> forcarAtualizacaoListaTemas() async {
    _isLoadingListaTemas = true;
    _errorListaTemas = null;
    notifyListeners();

    try {
      _temasEmMemoria = await _temasService.listarTemas();
    } catch (e) {
      _errorListaTemas = e.toString();
    } finally {
      _isLoadingListaTemas = false;
      notifyListeners();
    }
  }

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
      invalidarListaTemasEmMemoria();
      return tema['id'] as String;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> atualizarTema({
    required String id,
    required String nome,
    required String descricao,
    required List<String> modalidades,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _temasService.atualizarTema(
        id: id,
        nome: nome,
        descricao: descricao,
        modalidades: modalidades,
      );
      invalidarListaTemasEmMemoria();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletarTema(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _temasService.deletarTema(id);
      _temasEmMemoria?.removeWhere((t) => t.id == id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cria o tema e inicia a sessão de prática na API (`POST /vocab/practice/start`).
  Future<({PracticeSessionPayload session, String themeId})?> criarTemaEIniciarPratica({
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
      invalidarListaTemasEmMemoria();

      final themeId = tema['id'] as String;
      final session = await _vocabPracticeService.iniciarSessao(themeId: themeId);

      return (session: session, themeId: themeId);
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
