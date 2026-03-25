import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';

/// Resolves the current Firebase user's backend userId by matching email
/// against group members. Caches per groupId to avoid redundant API calls.
class UserIdentityService {
  UserIdentityService._();
  static final UserIdentityService instance = UserIdentityService._();

  final Map<String, String> _cache = {};

  /// Returns the backend userId for the current Firebase user in this group.
  /// Returns empty string if resolution fails.
  Future<String> getBackendUserId(String groupId) async {
    if (_cache.containsKey(groupId)) return _cache[groupId]!;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null || firebaseUser.email == null) return '';

    try {
      final members = await PaymentRepository().getGroupMembers(groupId);
      for (final m in members) {
        if (m.email.toLowerCase() == firebaseUser.email!.toLowerCase()) {
          _cache[groupId] = m.userId;
          return m.userId;
        }
      }
    } catch (_) {}
    return '';
  }

  void clearCache() => _cache.clear();
}
