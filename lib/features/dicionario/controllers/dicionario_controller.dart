import 'package:flutter/foundation.dart';
import '../models/dicionario_service.dart';
import '../models/palavra_model.dart';

class DicionarioController extends ChangeNotifier {
  final DicionarioService _service;
  DicionarioController(this._service);

  bool _isLoading = false;
  bool _isLoadingLista = false;
  String? _errorMessage;
  String? _errorLista;
  List<PalavraModel>? _palavras;
  bool _ultimaReativada = false;

  bool get isLoading => _isLoading;
  bool get isLoadingLista => _isLoadingLista;
  String? get errorMessage => _errorMessage;
  String? get errorLista => _errorLista;
  bool get ultimaReativada => _ultimaReativada;
  bool get listaJaCarregada => _palavras != null;

  List<PalavraModel> get palavras =>
      List<PalavraModel>.unmodifiable(_palavras ?? const []);

  Future<void> carregarSeNecessario() async {
    if (_palavras != null) return;
    await forcarAtualizacao();
  }

  Future<void> forcarAtualizacao() async {
    _isLoadingLista = true;
    _errorLista = null;
    notifyListeners();

    try {
      _palavras = await _service.listarPalavras();
    } catch (e) {
      _errorLista = e.toString();
    } finally {
      _isLoadingLista = false;
      notifyListeners();
    }
  }

  Future<bool> adicionarPalavra(String word) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.adicionarPalavra(word);
      _ultimaReativada = result.reativada;
      final jaExiste = _palavras?.any((p) => p.id == result.palavra.id) ?? false;
      if (jaExiste) {
        _palavras = _palavras?.map((p) => p.id == result.palavra.id ? result.palavra : p).toList();
      } else {
        _palavras = [result.palavra, ...?_palavras];
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removerPalavra(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.removerPalavra(id);
      _palavras?.removeWhere((p) => p.id == id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
