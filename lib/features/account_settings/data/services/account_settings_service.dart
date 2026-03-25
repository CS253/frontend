import '../../../../../core/api/api_client.dart';
import '../../../../../core/api/api_endpoints.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettingsService {
  final ApiClient apiClient;

  AccountSettingsService(this.apiClient);

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final response =
        await apiClient.get(ApiEndpoints.userProfile) as Map<String, dynamic>;
    final raw = response['data'] as Map<String, dynamic>? ?? {};

    return {
      'data': {
        'id': raw['id'],
        'name': raw['name'] ?? '',
        'email': raw['email'] ?? '',
        'phone': raw['phoneNumber'] ?? '',
        'upi_id': raw['upiId'] ?? '',
        'image_url': null,
        'preferences': {'notifications_enabled': true},
      },
    };
  }

  Future<void> updateNotificationPreferences(bool enabled) async {
    // MOCK RESPONSE
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await apiClient.put(
      ApiEndpoints.updateUserProfile,
      body: {
        if (data['name'] != null) 'name': data['name'],
        if (data['phone'] != null) 'phoneNumber': data['phone'],
        'upiId': data['upi_id'] ?? '',
      },
    );
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception('User not signed in');
      }

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw Exception('Incorrect current password');
      }
      throw Exception(e.message ?? 'Failed to change password');
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}
