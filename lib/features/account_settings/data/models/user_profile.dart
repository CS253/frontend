class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? imageUrl;
  final String upiId;
  final bool notificationsEnabled;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.imageUrl,
    required this.upiId,
    required this.notificationsEnabled,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      imageUrl: json['image_url'] as String?,
      upiId: json['upi_id'] as String? ?? '',
      notificationsEnabled:
          (json['preferences']?['notifications_enabled'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'image_url': imageUrl,
      'upi_id': upiId,
      'preferences': {'notifications_enabled': notificationsEnabled},
    };
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? imageUrl,
    String? upiId,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      imageUrl: imageUrl ?? this.imageUrl,
      upiId: upiId ?? this.upiId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
