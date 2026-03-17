import '../models/member_model.dart';
import '../models/trip_settings_model.dart';

class TripSettingsApiService {
  // TODO: MOCK - Remove this mock delay when switching to real backend
  Future<void> _mockNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  // Fetch Trip Members
  Future<List<MemberModel>> getTripMembers(String tripId) async {
    // TODO: MOCK - Replace with real GET request
    /*
    final url = Uri.parse('${ApiEndpoints.baseUrl}/trips/$tripId/members');
    final response = await http.get(url, headers: _getHeaders());
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((e) => MemberModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load members');
    }
    */

    await _mockNetworkDelay();
    return [
      MemberModel(
        id: '1',
        name: 'Sarah Chen',
        imageUrl:
            'https://ui-avatars.com/api/?name=Sarah+Chen&background=8E1C2E&color=fff',
        isAdmin: true,
        status: MemberStatusType.settled,
        amount: 0,
      ),
      MemberModel(
        id: '2',
        name: 'Marcus Johnson',
        imageUrl:
            'https://ui-avatars.com/api/?name=Marcus+Johnson&background=8E8E8E&color=fff',
        isAdmin: false,
        status: MemberStatusType.owes,
        amount: 600,
      ),
      MemberModel(
        id: '3',
        name: 'Sanket',
        imageUrl:
            'https://ui-avatars.com/api/?name=Sanket&background=4A6670&color=fff',
        isAdmin: false,
        status: MemberStatusType.gets,
        amount: 1200,
      ),
      MemberModel(
        id: '4',
        name: 'David Park',
        imageUrl:
            'https://ui-avatars.com/api/?name=David+Park&background=516A79&color=fff',
        isAdmin: false,
        status: MemberStatusType.settled,
        amount: 0,
      ),
      MemberModel(
        id: '5',
        name: 'Priya Sharma',
        imageUrl:
            'https://ui-avatars.com/api/?name=Priya+Sharma&background=3F51B5&color=fff',
        isAdmin: false,
        status: MemberStatusType.owes,
        amount: 200,
      ),
    ];
  }

  // Add Trip Member
  Future<MemberModel> addMember(String tripId, String phone) async {
    // TODO: MOCK - Replace with POST request
    /*
    final url = Uri.parse('${ApiEndpoints.baseUrl}/trips/$tripId/members');
    final response = await http.post(
      url, 
      headers: _getHeaders(),
      body: jsonEncode({"phone": phone}),
    );
    if (response.statusCode == 201) {
      return MemberModel.fromJson(jsonDecode(response.body)['data']['member']);
    } else {
      throw Exception('Failed to add member');
    }
    */

    await _mockNetworkDelay();
    return MemberModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'New User',
      imageUrl:
          'https://ui-avatars.com/api/?name=New+User&background=2EB867&color=fff',
      isAdmin: false,
      status: MemberStatusType.settled,
      amount: 0,
      phone: phone,
    );
  }

  // Remove Trip Member
  Future<void> removeMember(String tripId, String userId) async {
    // TODO: MOCK - Replace with DELETE request
    /*
    final url = Uri.parse('${ApiEndpoints.baseUrl}/trips/$tripId/members/$userId');
    final response = await http.delete(url, headers: _getHeaders());
    if (response.statusCode != 200) {
      throw Exception('Failed to remove member');
    }
    */
    await _mockNetworkDelay();
  }

  // Make Admin
  Future<void> setMemberAdminStatus(
    String tripId,
    String userId,
    bool isAdmin,
  ) async {
    // TODO: MOCK - Replace with PATCH request
    /*
    final url = Uri.parse('${ApiEndpoints.baseUrl}/trips/$tripId/members/$userId/role');
    final response = await http.patch(
      url, 
      headers: _getHeaders(),
      body: jsonEncode({"is_admin": isAdmin})
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update role');
    }
    */
    await _mockNetworkDelay();
  }

  // Get Trip App Settings
  Future<TripSettingsModel> getTripSettings(String tripId) async {
    // TODO: MOCK - Replace with GET request
    await _mockNetworkDelay();
    return TripSettingsModel(
      id: tripId,
      name: 'The Lyaari Trip',
      icon: '🏖️',
      simplifyExpenses: true,
    );
  }

  // Update Trip App Settings
  Future<void> updateTripSettings(
    String tripId,
    Map<String, dynamic> data,
  ) async {
    // TODO: MOCK - Replace with PATCH request
    await _mockNetworkDelay();
  }

  // Get Notification Preferences
  Future<NotificationSettingsModel> getNotificationSettings(
    String tripId,
  ) async {
    // TODO: MOCK - Replace with GET request
    await _mockNetworkDelay();
    return NotificationSettingsModel(
      tripAlerts: true,
      expenseSplit: true,
      paymentReminders: true,
      routeUpdates: false,
      removalNotifications: false,
      largeExpenses: false,
    );
  }

  // Update Notification Preferences
  Future<void> updateNotificationSettings(
    String tripId,
    Map<String, dynamic> data,
  ) async {
    // TODO: MOCK - Replace with PATCH request
    await _mockNetworkDelay();
  }

  /*
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      // 'Authorization': 'Bearer YOUR_TOKEN', // Uncomment when adding actual auth
    };
  }
  */
}
