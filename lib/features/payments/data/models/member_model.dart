import 'package:flutter/material.dart';

/// Data model representing a trip member.
class MemberModel {
  final String id;
  final String initials;
  final String name;
  final Color avatarColor;

  const MemberModel({
    required this.id,
    required this.initials,
    required this.name,
    required this.avatarColor,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      name: json['name'] as String? ?? '',
      avatarColor: Color(json['avatar_color'] as int? ?? 0xFF87D4F8),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'initials': initials,
      'name': name,
      'avatar_color': avatarColor.toARGB32(),
    };
  }
}

/// Default trip members (mock data).
final List<MemberModel> defaultTripMembers = [
  const MemberModel(
    id: '1',
    initials: 'K',
    name: 'Kashish',
    avatarColor: Color(0xFF9FDFCA),
  ),
  const MemberModel(
    id: '2',
    initials: 'HP',
    name: 'Hipalantya',
    avatarColor: Color(0xFFFABD9E),
  ),
  const MemberModel(
    id: '3',
    initials: 'RU',
    name: 'Rushabh',
    avatarColor: Color(0xFFCCB3E6),
  ),
  const MemberModel(
    id: '4',
    initials: 'AS',
    name: 'Ashish',
    avatarColor: Color(0xFF87D4F8),
  ),
  const MemberModel(
    id: '5',
    initials: 'ME',
    name: 'You',
    avatarColor: Color(0xFF87D4F8),
  ),
];
