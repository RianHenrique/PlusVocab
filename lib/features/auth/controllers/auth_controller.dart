import 'package:flutter/foundation.dart';
import '../models/auth_service.dart';
import '../../../core/common_models/user_model.dart';

class AuthController extends ChangeNotifier {
  
  final AuthService _authService;

  AuthController(this._authService);

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;


  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  Future<void> signUp({
    required String email,
    required String password,
    required String confirmPassword
  }) async {
    _isLoading = true;
    _errorMessage = null; 
    notifyListeners(); 

    try {
      _currentUser = await _authService.signUp(email: email, password: password, confirmPassword: confirmPassword);
      debugPrint('Usuário cadastrado com sucesso: $_currentUser');

    } catch (e) {
      _errorMessage = e.toString();
      
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Você adicionaria outras funções aqui
  // Future<void> login({required String email, required String password}) async { ... }
  // Future<void> logout() async { ... }
}