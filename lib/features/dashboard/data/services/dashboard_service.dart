import 'package:travelly/core/api/api_client.dart';
import 'package:travelly/core/api/api_endpoints.dart';
import 'package:travelly/core/constants/currency.dart';

class DashboardService {
  final ApiClient _apiClient;

  DashboardService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  static const Map<String, String> _currencySymbols = {
    'INR': 'Rs.',
    'USD': '\$',
    'EUR': 'EUR ',
    'GBP': 'GBP ',
    'JPY': 'JPY ',
  };

  Future<Map<String, dynamic>> fetchDashboard(String tripId) async {
    final responses = await Future.wait<dynamic>([
      _apiClient.get(ApiEndpoints.groupDetails(tripId)),
      _apiClient.get(ApiEndpoints.groupMembers(tripId)),
    ]);

    final groupResponse = responses[0] as Map<String, dynamic>;
    final membersResponse = responses[1] as Map<String, dynamic>;

    final group = groupResponse['data'] as Map<String, dynamic>? ?? {};
    final membersRaw = membersResponse['members'] as List<dynamic>? ?? const [];
    final participants = membersRaw
        .map((member) => _mapParticipant(member as Map<String, dynamic>))
        .toList();

    List<Map<String, dynamic>> recentActivities = [];
    try {
      final historyResponse =
          await _apiClient.get(ApiEndpoints.groupHistory(tripId)) as Map<String, dynamic>;
      final history = historyResponse['data'] as List<dynamic>? ?? const [];
      recentActivities = history
          .map((item) => _mapActivity(item as Map<String, dynamic>))
          .take(5)
          .toList();
    } catch (_) {
      recentActivities = [];
    }

    return {
      'currentTrip': _mapTrip(group, participants.length),
      'participants': participants,
      'recentActivities': recentActivities,
    };
  }

  /// Fetches only the group/trip detail record.
  Future<Map<String, dynamic>?> fetchTripDetails(String tripId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.groupDetails(tripId)) as Map<String, dynamic>;
      final group = response['data'] as Map<String, dynamic>? ?? {};
      // Use a placeholder membersCount=0 — the real count will come from fetchTripMembers
      return _mapTrip(group, 0);
    } catch (_) {
      return null;
    }
  }

  /// Fetches only the member list for the trip.
  Future<List<Map<String, dynamic>>> fetchTripMembers(String tripId) async {
    final response = await _apiClient.get(ApiEndpoints.groupMembers(tripId)) as Map<String, dynamic>;
    final membersRaw = response['members'] as List<dynamic>? ?? const [];
    return membersRaw
        .map((m) => _mapParticipant(m as Map<String, dynamic>))
        .toList();
  }

  /// Fetches only the activity/history log for the trip (latest 5).
  Future<List<Map<String, dynamic>>> fetchTripActivities(String tripId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.groupHistory(tripId)) as Map<String, dynamic>;
      final history = response['data'] as List<dynamic>? ?? const [];
      return history
          .map((item) => _mapActivity(item as Map<String, dynamic>))
          .take(5)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> updateTrip({
    required String tripId,
    required String name,
    required String destination,
    required String startDate,
    required String endDate,
    required String tripType,
    required String emoji,
    String? coverImagePath,
  }) async {
    final hasNewCoverUpload =
        coverImagePath != null &&
        coverImagePath.isNotEmpty &&
        !coverImagePath.startsWith('http');

    final response = await _apiClient.put(
      ApiEndpoints.tripById(tripId),
      body: {
        'title': name,
        'destination': destination,
        'startDate': startDate,
        'endDate': endDate,
        'tripType': tripType,
        'emoji': emoji,
      },
    );

    if (hasNewCoverUpload) {
      await _apiClient.putMultipart(
        ApiEndpoints.groupPhoto(tripId),
        fields: const {},
        fileFieldName: 'photo',
        filePath: coverImagePath,
      );
    }

    return response;
  }

  Map<String, dynamic> _mapTrip(
    Map<String, dynamic> group,
    int memberCount,
  ) {
    final destination = (group['destination'] as String? ?? '').trim();
    final tripType = (group['tripType'] as String? ?? 'Other').trim();
    final coverImage = (group['coverImage'] as String? ?? group['photoUrl'] as String?)?.trim();

    return {
      'id': group['id'] as String? ?? '',
      'name': group['title'] as String? ?? 'Untitled Trip',
      'location': _locationLabel(destination),
      'destination': destination,
      'startDate': group['startDate'] as String? ?? '',
      'endDate': group['endDate'] as String? ?? '',
      'daysRemaining': _calculateDaysRemaining(group['startDate'] as String?),
      'emoji': _tripEmojiForType(tripType),
      'tripType': tripType.isEmpty ? 'Other' : tripType,
      'coverImage': coverImage != null && coverImage.isNotEmpty ? coverImage : null,
      'membersCount': memberCount,
      'simplifyDebts': group['simplifyDebts'] as bool? ?? false,
    };
  }

  Map<String, dynamic> _mapParticipant(Map<String, dynamic> member) {
    final name = (member['name'] as String? ?? 'Traveller').trim();

    return {
      'id': member['id'] as String? ?? '',
      'name': name.isEmpty ? 'Traveller' : name,
      'avatarUrl': member['avatarUrl'] as String? ?? '',
      'emoji': _memberEmoji(name),
    };
  }

  Map<String, dynamic> _mapActivity(Map<String, dynamic> item) {
    final payer = item['payer'] as Map<String, dynamic>? ?? const {};
    final actor = (payer['name'] as String? ?? 'Someone').trim();
    final amountLabel =
        '${_currencyPrefix(item['currency'] as String?)}${_formatAmount(item['amount'])}';
    final title = (item['title'] as String? ?? 'expense').trim();
    final isReimbursement =
        (item['type'] as String? ?? '').toUpperCase() == 'REIMBURSEMENT';

    return {
      'id': item['id'] as String? ?? '',
      'type': 'payment_added',
      'actor': actor.isEmpty ? 'Someone' : actor,
      'description': isReimbursement
          ? 'recorded reimbursement of $amountLabel for $title'
          : 'added $amountLabel for $title',
      'timestamp': item['createdAt'] as String? ?? item['date'] as String? ?? '',
      'iconType': 'payment',
    };
  }

  String _tripEmojiForType(String tripType) {
    switch (tripType) {
      case 'Beach':
        return 'Beach';
      case 'Mountain':
        return 'Mountain';
      case 'City':
        return 'City';
      case 'Nature':
        return 'Nature';
      case 'Island':
        return 'Island';
      default:
        return 'Trip';
    }
  }

  String _memberEmoji(String name) {
    const emojis = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    if (name.isEmpty) return emojis.first;
    final index = name.codeUnits.fold<int>(0, (sum, code) => sum + code) % emojis.length;
    return emojis[index];
  }

  int _calculateDaysRemaining(String? startDate) {
    if (startDate == null || startDate.isEmpty) return 0;

    final parsed = DateTime.tryParse(startDate);
    if (parsed == null) return 0;

    final today = DateTime.now();
    final tripStart = DateTime(parsed.year, parsed.month, parsed.day);
    final currentDate = DateTime(today.year, today.month, today.day);
    final difference = tripStart.difference(currentDate).inDays;

    return difference < 0 ? 0 : difference;
  }

  String _locationLabel(String destination) {
    if (destination.trim().isEmpty) return 'Unknown';
    return destination.split(',').first.trim();
  }

  String _formatAmount(dynamic amount) {
    if (amount is num) {
      return amount % 1 == 0 ? amount.toInt().toString() : amount.toStringAsFixed(2);
    }
    return amount?.toString() ?? '0';
  }

  String _currencyPrefix(String? currency) {
    if (currency == null || currency.isEmpty) return AppCurrency.symbol;
    return _currencySymbols[currency] ?? '$currency ';
  }
}
