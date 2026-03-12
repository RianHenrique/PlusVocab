import 'package:flutter/foundation.dart';
import '../models/auth_service.dart';
import '../../../core/common_models/user_model.dart';


class AuthController extends ChangeNotifier {
  
  final AuthService _authService;
  

  AuthController(this._authService);

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  bool? _emailEnviado;
  String? _recoveryToken;


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

  Future<void> signIn({
    required String email, 
    required String password
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      
      _currentUser = await _authService.signIn(email: email, password: password);
      debugPrint('Usuário logado com sucesso: $_currentUser');

    } catch (e) {
      _errorMessage = e.toString();

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendRecoveryEmail({
    required String email, 
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      
      _emailEnviado = await _authService.sendRecoveryEmail(email: email);
      debugPrint('Email enviado com sucesso: $_emailEnviado');

    } catch (e) {
      _errorMessage = e.toString();

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> sendRecoveryCode({
    required String email, 
    required String code
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      
      _recoveryToken = await _authService.sendRecoveryCode(email: email, code: code);
      debugPrint('Código enviado com sucesso. O token é: $_recoveryToken');
      return _recoveryToken;

    } catch (e) {
      _errorMessage = e.toString();
      return null;

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword({
    required String email, 
    required String resetToken,
    required String newPassword
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email: email, resetToken: resetToken, newPassword: newPassword);

    } catch (e) {
      _errorMessage = e.toString();

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async { 
    _currentUser = null;
    notifyListeners();
  }
}