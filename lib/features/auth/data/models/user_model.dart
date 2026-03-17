// =============================================================================
// User Model — Represents a user in the Travelly app.
//
// Maps directly to the user object returned by the backend:
// {
//   "id": "uuid",
//   "name": "John Doe",
//   "email": "john@email.com",
//   "phone": "+1234567890"
// }
//
// TODO: Add additional fields as backend user model evolves.
// =============================================================================

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
  });

  /// Creates a UserModel from API JSON response.
  /// TODO: Update field names if backend uses different keys.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Converts the UserModel to a JSON map for API requests / local storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
    };
  }

  /// Creates a copy of this UserModel with optional field overrides.
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email)';
}
