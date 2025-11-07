// lib/core/common_models/user_model.dart

class User {
  final String id;
  final String email;
  final String accessToken; 
  final String refreshToken;

  // Adicione outros campos que sua API retornar (ex: avatarUrl, etc.)

  const User({
    required this.id,
    required this.email,
    required this.accessToken,
    required this.refreshToken
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['data']['user']['id'],
      email: json['data']["user"]['email'],
      accessToken: json['data']['tokens']["accessToken"],
      refreshToken: json['data']['tokens']["refreshToken"],
    );
  }

  /// Método para converter uma instância de User em um JSON
  /// (útil para enviar dados em um POST ou PUT)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'acceessToken': accessToken,
      'refreshToken': refreshToken
    };
  }

  @override
  String toString() {
    // Isso define como o User será "printado"
    return 'User(id: $id, email: $email, accessToken: $accessToken, refreshToken: $refreshToken)';
  }
}