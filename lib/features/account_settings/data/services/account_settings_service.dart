import '../../../../../core/api/api_client.dart';

class AccountSettingsService {
  final ApiClient apiClient;

  AccountSettingsService(this.apiClient);

  Future<Map<String, dynamic>> fetchUserProfile() async {
    // try {
    //   final response = await apiClient.get(ApiEndpoints.userProfile);
    //   return response.data;
    // } catch (e) {
    //   rethrow;
    // }

    // MOCK RESPONSE
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Simulate network latency
    return {
      "data": {
        "id": "u_12345",
        "name": "Aditya Sharma",
        "email": "aditya.sharma@email.com",
        "phone": "+91 9876543210",
        "address": "123 Travelly Street, Mumbai, India",
        "upi_id": "aditya.sharma@okicici",
        "image_url": "https://randomuser.me/api/portraits/men/32.jpg",
        "preferences": {"notifications_enabled": true},
      },
    };
  }

  Future<void> updateNotificationPreferences(bool enabled) async {
    // MOCK RESPONSE
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    // MOCK RESPONSE
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    // MOCK RESPONSE
    await Future.delayed(const Duration(seconds: 1));
    if (currentPassword == 'wrongpassword') {
      throw Exception('Incorrect current password');
    }
  }
}
