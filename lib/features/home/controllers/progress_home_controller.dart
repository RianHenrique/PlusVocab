import 'package:flutter/foundation.dart';
import 'package:plus_vocab/features/home/models/progress_home.dart';
import 'package:plus_vocab/features/home/models/progress_home_service.dart';

class ProgressHomeController extends ChangeNotifier {
  ProgressHomeController(this._service);

  final ProgressHomeService _service;

  ProgressHome? _data;
  bool _isLoading = false;
  String? _errorMessage;

  ProgressHome? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> carregar() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _service.fetchHome();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> atualizar() => carregar();
}
