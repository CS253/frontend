import 'package:flutter/material.dart';

import '../../data/models/member_model.dart';
import '../../data/models/trip_settings_model.dart';
import '../../data/repositories/trip_settings_repository.dart';

class TripSettingsProvider extends ChangeNotifier {
  final TripSettingsRepository _repository;

  TripSettingsProvider(this._repository);

  // Provide a generic tripId for now. When navigating from another part of the app, this should be set or passed in.
  String _tripId = 't_123';
  String get currentTripId => _tripId;

  // --- State for Members ---
  bool _isLoadingMembers = false;
  bool get isLoadingMembers => _isLoadingMembers;

  List<MemberModel> _members = [];
  List<MemberModel> get members => _members;

  String? _membersError;
  String? get membersError => _membersError;

  // --- State for Trip Settings ---
  bool _isLoadingTripSettings = false;
  bool get isLoadingTripSettings => _isLoadingTripSettings;

  TripSettingsModel? _tripSettings;
  TripSettingsModel? get tripSettings => _tripSettings;

  String? _tripSettingsError;
  String? get tripSettingsError => _tripSettingsError;

  // --- State for Notification Settings ---
  bool _isLoadingNotifications = false;
  bool get isLoadingNotifications => _isLoadingNotifications;

  NotificationSettingsModel? _notificationSettings;
  NotificationSettingsModel? get notificationSettings => _notificationSettings;

  String? _notificationError;
  String? get notificationError => _notificationError;

  // ---------------------------------------------------------------------------
  // INTIALIZATION
  // ---------------------------------------------------------------------------
  void init(String tripId) {
    _tripId = tripId;
    fetchMembers();
    fetchTripSettings();
    fetchNotificationSettings();
  }

  // ---------------------------------------------------------------------------
  // MEMBERS METHODS
  // ---------------------------------------------------------------------------
  Future<void> fetchMembers() async {
    _isLoadingMembers = true;
    _membersError = null;
    notifyListeners();

    try {
      _members = await _repository.getTripMembers(_tripId);
    } catch (e) {
      _membersError = e.toString();
    } finally {
      _isLoadingMembers = false;
      notifyListeners();
    }
  }

  Future<void> addMember(String phone) async {
    try {
      final newMember = await _repository.addMember(_tripId, phone);
      _members.add(newMember);
      notifyListeners();
    } catch (e) {
      // Handle the error, maybe show a toast in UI instead of setting state directly completely.
      debugPrint('Error adding member: $e');
      rethrow;
    }
  }

  Future<void> removeMember(String userId) async {
    try {
      await _repository.removeMember(_tripId, userId);
      _members.removeWhere((m) => m.id == userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing member: $e');
      rethrow;
    }
  }

  Future<void> setAdminStatus(String userId, bool isAdmin) async {
    try {
      await _repository.setMemberAdminStatus(_tripId, userId, isAdmin);
      final index = _members.indexWhere((m) => m.id == userId);
      if (index >= 0) {
        final existing = _members[index];
        _members[index] = MemberModel(
          id: existing.id,
          name: existing.name,
          imageUrl: existing.imageUrl,
          isAdmin: isAdmin,
          status: existing.status,
          amount: existing.amount,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error setting admin status: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // TRIP APP SETTINGS METHODS
  // ---------------------------------------------------------------------------
  Future<void> fetchTripSettings() async {
    _isLoadingTripSettings = true;
    _tripSettingsError = null;
    notifyListeners();

    try {
      _tripSettings = await _repository.getTripSettings(_tripId);
    } catch (e) {
      _tripSettingsError = e.toString();
    } finally {
      _isLoadingTripSettings = false;
      notifyListeners();
    }
  }

  Future<void> updateTripSetting(String key, dynamic value) async {
    // Optimistic UI Update
    if (_tripSettings != null) {
      if (key == 'simplify_expenses') {
         _tripSettings = _tripSettings!.copyWith(simplifyExpenses: value);
         notifyListeners();
      }
    }

    try {
      await _repository.updateTripSettings(_tripId, {key: value});
    } catch (e) {
      // Rollback on failure could be implemented here
      debugPrint('Error updating trip setting: $e');
      fetchTripSettings(); // Re-sync with backend
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // NOTIFICATION METHODS
  // ---------------------------------------------------------------------------
  Future<void> fetchNotificationSettings() async {
    _isLoadingNotifications = true;
    _notificationError = null;
    notifyListeners();

    try {
      _notificationSettings = await _repository.getNotificationSettings(_tripId);
    } catch (e) {
      _notificationError = e.toString();
    } finally {
      _isLoadingNotifications = false;
      notifyListeners();
    }
  }

  Future<void> updateNotificationSetting(String key, dynamic value) async {
    // Optimistic UI Update
    if (_notificationSettings != null) {
       switch (key) {
         case 'trip_alerts':
           _notificationSettings = _notificationSettings!.copyWith(tripAlerts: value);
           break;
         case 'expense_split':
           _notificationSettings = _notificationSettings!.copyWith(expenseSplit: value);
           break;
         case 'payment_reminders':
           _notificationSettings = _notificationSettings!.copyWith(paymentReminders: value);
           break;
         case 'route_updates':
           _notificationSettings = _notificationSettings!.copyWith(routeUpdates: value);
           break;
         case 'removal_notifications':
           _notificationSettings = _notificationSettings!.copyWith(removalNotifications: value);
           break;
         case 'large_expenses':
           _notificationSettings = _notificationSettings!.copyWith(largeExpenses: value);
           break;
       }
       notifyListeners();
    }

    try {
      await _repository.updateNotificationSettings(_tripId, {key: value});
    } catch (e) {
      debugPrint('Error updating notification setting: $e');
      fetchNotificationSettings();
      rethrow;
    }
  }
}
