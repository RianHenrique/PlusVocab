import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/common_models/user_model.dart';
import '../../../core/common_models/user_profile.dart';
import '../../../core/services/storage_service.dart';
import '../../temas/models/tema_resumo.dart';
import '../models/auth_service.dart';
import '../models/authenticated_session.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService;

  AuthController(this._authService);

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  UserProfile? _userProfile;
  List<TemaResumo> _themesFromLogin = [];
  bool? _emailEnviado;
  String? _recoveryToken;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  List<TemaResumo> get themesFromLogin => List<TemaResumo>.unmodifiable(_themesFromLogin);

  /// Perfil incompleto quando ausente ou sem nome (ex.: após cadastro ou login Google).
  bool get needsProfileOnboarding {
    final profile = _userProfile;
    if (profile == null) return true;
    return profile.name.trim().isEmpty;
  }

  void _applySession(AuthenticatedSession session) {
    _currentUser = session.user;
    _userProfile = session.profile;
    _themesFromLogin = List<TemaResumo>.from(session.themesFromLogin);
  }

  Future<void> restoreSessionFromStorage() async {
    final email = await _authService.storage.getUserEmail();
    final userId = await _authService.storage.getUserId();
    final access = await _authService.storage.getAccessToken();
    final refresh = await _authService.storage.getRefreshToken();
    if (email != null &&
        email.isNotEmpty &&
        userId != null &&
        userId.isNotEmpty &&
        access != null &&
        access.isNotEmpty &&
        refresh != null &&
        refresh.isNotEmpty) {
      _currentUser = User(
        id: userId,
        email: email,
        accessToken: access,
        refreshToken: refresh,
      );
    }
    final profileRaw = await _authService.storage.getUserProfileJson();
    if (profileRaw != null && profileRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(profileRaw);
        if (decoded is Map<String, dynamic>) {
          _userProfile = UserProfile.fromJson(decoded);
        } else {
          _userProfile = null;
        }
      } catch (_) {
        _userProfile = null;
      }
    } else {
      _userProfile = null;
    }
    final themesRaw = await _authService.storage.getThemesFromLoginJson();
    final themeMaps = StorageService.decodeThemesFromLoginJson(themesRaw);
    _themesFromLogin =
        themeMaps.map((m) => TemaResumo.fromLoginSummary(m)).toList();
    notifyListeners();
  }

  Future<bool> checkAuthStatus() async {
    final refreshToken = await _authService.storage.getRefreshToken();
    final userId = await _authService.storage.getUserId();
    
    if (refreshToken == null || refreshToken.isEmpty || userId == null || userId.isEmpty) {
      return false;
    }

    try {
      bool authStatus = await _authService.refreshAcessToken();
      if (authStatus) {
        await restoreSessionFromStorage();
      }
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
      _userProfile = null;
      _themesFromLogin = [];
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
      final session = await _authService.signIn(email: email, password: password);
      _applySession(session);
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
          final session = await _authService.authGoogle(serverAuthCode: serverAuthCode);
          _applySession(session);
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

  Future<void> updateCachedUserProfile(UserProfile profile) async {
    _userProfile = profile;
    final themesRaw = await _authService.storage.getThemesFromLoginJson();
    await _authService.storage.saveSessionPresentation(
      profileJson: jsonEncode(profile.toJson()),
      themesFromLoginJson: themesRaw,
    );
    notifyListeners();
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
      _userProfile = null;
      _themesFromLogin = [];
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
      _userProfile = null;
      _themesFromLogin = [];
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