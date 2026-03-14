// =============================================================================
// Member Model — Represents a trip member.
//
// Maps to the member object returned by GET /trips/{tripId}/members:
// {
//   "id": "uuid",
//   "name": "John Doe",
//   "phone": "+1234567890",
//   "role": "member",
//   "avatarUrl": "https://..."
// }
// =============================================================================

class MemberModel {
  final String id;
  final String name;
  final String? phone;
  final String role;
  final String? avatarUrl;

  MemberModel({
    required this.id,
    required this.name,
    this.phone,
    this.role = 'member',
    this.avatarUrl,
  });

  /// Creates a MemberModel from API JSON response.
  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'member',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  /// Converts to JSON map for API requests.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }

  /// Creates a copy with optional field overrides.
  MemberModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? role,
    String? avatarUrl,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() => 'MemberModel(id: $id, name: $name)';
}
