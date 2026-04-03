import 'package:flutter/material.dart';
import '../../../../core/utils/initials_util.dart';

/// Data model representing a group member.
///
/// Maps to the member object within GET /groups/:groupId response:
/// ```json
/// { "id": "member-1", "userId": "user-123", "groupId": "group-123",
///   "user": { "id": "user-123", "name": "John Doe", "email": "john@example.com" } }
/// ```
class MemberModel {
  final String id;        // membership ID
  final String userId;    // actual user ID (used in API calls)
  final String groupId;
  final String name;
  final String email;
  final Color avatarColor;

  const MemberModel({
    required this.id,
    required this.userId,
    this.groupId = '',
    required this.name,
    this.email = '',
    required this.avatarColor,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    // Support both nested group-member format and flat format
    final name = user?['name'] as String? ?? json['name'] as String? ?? '';
    final email = user?['email'] as String? ?? json['email'] as String? ?? '';
    final userId = user?['id'] as String? ?? json['userId'] as String? ?? json['id'] as String? ?? '';

    return MemberModel(
      id: json['id'] as String? ?? '',
      userId: userId,
      groupId: json['groupId'] as String? ?? '',
      name: name,
      email: email,
      avatarColor: Color(json['avatar_color'] as int? ?? _colorFromName(name)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'groupId': groupId,
      'name': name,
      'email': email,
      'avatar_color': avatarColor.toARGB32(),
    };
  }

  /// Generate initials from name (e.g. "John Doe" → "JD").
  String get initials => getInitials(name);

  /// Derive a deterministic color from a name.
  static int _colorFromName(String name) {
    if (name.isEmpty) return 0xFF87D4F8;
    final colors = [
      0xFF9FDFCA, 0xFFFABD9E, 0xFFCCB3E6, 0xFF87D4F8,
      0xFFFFB3B3, 0xFFB3FFB3, 0xFFB3B3FF, 0xFFFFFFB3,
      0xFFFFB3FF, 0xFFB3FFFF, 0xFFFAE39E, 0xFFD8F1FD,
    ];
    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return colors[hash.abs() % colors.length];
  }
}
