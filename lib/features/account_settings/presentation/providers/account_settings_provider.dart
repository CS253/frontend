import 'package:flutter/foundation.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/account_settings_repository.dart';

class AccountSettingsProvider extends ChangeNotifier {
  final AccountSettingsRepository _repository;

  AccountSettingsProvider(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userProfile = await _repository.getUserProfile();
    } catch (e) {
      _errorMessage = 'Failed to load profile. Please try again.';
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleNotifications(bool value) async {
    if (_userProfile == null) return;

    // Optimistic UI update
    final previousValue = _userProfile!.notificationsEnabled;
    _userProfile = _userProfile!.copyWith(notificationsEnabled: value);
    notifyListeners();

    try {
      await _repository.updateNotificationPreferences(value);
    } catch (e) {
      // Revert if failed
      _userProfile = _userProfile!.copyWith(
        notificationsEnabled: previousValue,
      );
      _errorMessage = 'Failed to update preferences.';
      notifyListeners();
      debugPrint('Error updating preferences: $e');
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String upiId,
  }) async {
    if (_userProfile == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateProfile({
        'name': name,
        'email': email,
        'phone': phone,
        'upi_id': upiId,
      });
      // Optimistic update locally
      _userProfile = _userProfile!.copyWith(
        name: name,
        email: email,
        phone: phone,
        upiId: upiId,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update profile details.';
      notifyListeners();
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.changePassword(currentPassword, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      final errorMsg = e.toString();
      if (errorMsg.contains('Incorrect current password')) {
        _errorMessage = 'Incorrect current password';
      } else {
        _errorMessage = 'Failed to change password. Please try again.';
      }
      notifyListeners();
      debugPrint('Error changing password: $e');
      return false;
    }
  }
}
