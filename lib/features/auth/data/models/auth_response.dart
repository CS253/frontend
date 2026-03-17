// =============================================================================
// Auth Response Model — Wraps login/register API responses.
//
// Encapsulates token + user data returned after successful authentication.
// {
//   "token": "jwt-token",
//   "user": { "id": "...", "name": "...", "email": "..." }
// }
// =============================================================================

import 'user_model.dart';

class AuthResponse {
  final String token;
  final UserModel user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  /// Creates an AuthResponse from API JSON response.
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}
