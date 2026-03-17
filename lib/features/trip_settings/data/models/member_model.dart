enum MemberStatusType { settled, owes, gets }

class MemberModel {
  final String id;
  final String name;
  final String imageUrl;
  final bool isAdmin;
  final MemberStatusType status;
  final double amount;
  final String? phone;

  MemberModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isAdmin,
    required this.status,
    required this.amount,
    this.phone,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    // TODO: MOCK - When integrating with real API, replace this factory logic according to your JSON schema map.
    return MemberModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      imageUrl: json['image_url'] as String? ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,
      status: _statusFromString(json['status'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image_url': imageUrl,
      'is_admin': isAdmin,
      'status': status.name,
      'amount': amount,
      'phone': phone,
    };
  }

  static MemberStatusType _statusFromString(String? statusStr) {
    switch (statusStr?.toLowerCase()) {
      case 'owes':
        return MemberStatusType.owes;
      case 'gets':
        return MemberStatusType.gets;
      case 'settled':
      default:
        return MemberStatusType.settled;
    }
  }
}
