import 'package:flutter/foundation.dart';
import '../models/auth_service.dart';
import '../../../core/common_models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';


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

  Future<bool> checkAuthStatus() async {
    final refreshToken = await _authService.storage.getRefreshToken();
    final userId = await _authService.storage.getUserId();
    
    if (refreshToken == null || refreshToken.isEmpty || userId == null || userId.isEmpty) {
      return false;
    }

    try {
      bool authStatus = await _authService.refreshAcessToken();
      return authStatus;
    } catch (e) {
      await _authService.storage.clearAuthData();
      return false;
    }
  }

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

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await _deepClean();

    // 1. Inicializa a configuração (scopings podem ser adicionados se necessário)
    GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: "513254980783-0mc882kqo0rdkhtc1qbr4fi3aal8h01o.apps.googleusercontent.com",
      scopes: ['email', 'profile'],
    );

    try {
      // await googleSignIn.disconnect();
      // 2. Inicia o processo de login (abre a folha de seleção de conta)
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        // 3. Obtém os detalhes da autenticação
        // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final String? serverAuthCode = googleUser.serverAuthCode;

        // 4. Aqui estão os tokens que você precisa
        // String? accessToken = googleAuth.accessToken;
        // String? idToken = googleAuth.idToken;

        // debugPrint("Access Token: $accessToken");
        // debugPrint("ID Token: $idToken");

        if (serverAuthCode != null){
          _currentUser = await _authService.authGoogle(serverAuthCode: serverAuthCode);
          debugPrint('Usuário logado com sucesso: $_currentUser');
        } else {
          debugPrint("Erro: serverAuthCode veio nulo. Verifique o serverClientId.");
        }

        // _currentUser = User(
        //   id: googleUser.id,
        //   email: googleUser.email,
        //   accessToken: accessToken!,
        //   refreshToken: idToken!,
        // );
        
        // Agora você pode enviar esse idToken para o seu backend para validação
      }
      if (googleUser == null) {
        return;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logOut() async { 
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: "513254980783-0mc882kqo0rdkhtc1qbr4fi3aal8h01o.apps.googleusercontent.com",
    );

    try {
      await _authService.logOut();
      _currentUser = null;
      await googleSignIn.signOut();
      debugPrint('Usuário deslogado com sucesso');
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

  }

  // No seu AuthController
  Future<void> _deepClean() async {
    try {
      // 1. PRIMEIRO: Limpa o storage. 
      // Assim, o Interceptor não terá 'accessToken' para anexar a nenhuma chamada.
      await _authService.storage.clearAuthData();
      
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();

      // 2. DEPOIS: Limpa o Google
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: "513254980783-0mc882kqo0rdkhtc1qbr4fi3aal8h01o.apps.googleusercontent.com",
      );

      // SignOut é local, raramente dá erro.
      await googleSignIn.signOut();

      // Disconnect pode tentar ir na rede. 
      // Como o storage já foi limpo acima, o Interceptor irá sem token (o que é correto).
      try {
        await googleSignIn.disconnect();
      } catch (e) {
        debugPrint("Google disconnect ignorado: $e");
      }
    } catch (e) {
      debugPrint("Erro na limpeza profunda: $e");
    }
  }
}