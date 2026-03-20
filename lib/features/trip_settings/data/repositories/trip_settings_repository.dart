import '../models/member_model.dart';
import '../models/trip_settings_model.dart';
import '../services/trip_settings_api_service.dart';

class TripSettingsRepository {
  final TripSettingsApiService _apiService;

  TripSettingsRepository(this._apiService);

  Future<List<MemberModel>> getTripMembers(String tripId) async {
    return await _apiService.getTripMembers(tripId);
  }

  Future<MemberModel> addMember(String tripId, String phone) async {
    return await _apiService.addMember(tripId, phone);
  }

  Future<void> removeMember(String tripId, String userId) async {
    await _apiService.removeMember(tripId, userId);
  }

  Future<void> setMemberAdminStatus(String tripId, String userId, bool isAdmin) async {
    await _apiService.setMemberAdminStatus(tripId, userId, isAdmin);
  }

  Future<TripSettingsModel> getTripSettings(String tripId) async {
    return await _apiService.getTripSettings(tripId);
  }

  Future<void> updateTripSettings(String tripId, Map<String, dynamic> data) async {
    await _apiService.updateTripSettings(tripId, data);
  }

  Future<NotificationSettingsModel> getNotificationSettings(String tripId) async {
    return await _apiService.getNotificationSettings(tripId);
  }

  Future<void> updateNotificationSettings(String tripId, Map<String, dynamic> data) async {
    await _apiService.updateNotificationSettings(tripId, data);
  }
}
