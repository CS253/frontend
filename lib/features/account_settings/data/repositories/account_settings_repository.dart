import '../models/user_profile.dart';
import '../services/account_settings_service.dart';

class AccountSettingsRepository {
  final AccountSettingsService _service;

  AccountSettingsRepository(this._service);

  Future<UserProfile> getUserProfile() async {
    final response = await _service.fetchUserProfile();
    final data = response['data'] as Map<String, dynamic>;
    return UserProfile.fromJson(data);
  }

  Future<void> updateNotificationPreferences(bool enabled) async {
    await _service.updateNotificationPreferences(enabled);
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _service.updateProfile(data);
  }

  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await _service.changePassword(currentPassword, newPassword);
  }
}
