import 'package:plus_vocab/core/common_models/user_model.dart';
import 'package:plus_vocab/core/common_models/user_profile.dart';
import 'package:plus_vocab/features/temas/models/tema_resumo.dart';

class AuthenticatedSession {
  const AuthenticatedSession({
    required this.user,
    this.profile,
    this.themesFromLogin = const [],
  });

  final User user;
  final UserProfile? profile;
  final List<TemaResumo> themesFromLogin;
}
