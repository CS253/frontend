/// Data model representing a single recent-activity feed item.
///
/// Maps to elements in the `recentActivities` array from the
/// GET /dashboard API response.
class ActivityModel {
  /// Unique activity identifier.
  final String id;

  /// Activity type string from backend (e.g. "payment_added", "photo_shared",
  /// "document_uploaded"). Used to determine the display emoji via [emoji].
  final String type;

  /// Name of the user who performed the action.
  final String actor;

  /// Human-readable description (e.g. "added ₹10000 for Hotel").
  final String description;

  /// ISO-8601 timestamp string of when the activity occurred.
  final String timestamp;

  /// Icon/emoji category hint from the backend (e.g. "payment", "photo", "document").
  /// Falls back to [type] if not provided.
  final String iconType;

  const ActivityModel({
    required this.id,
    required this.type,
    required this.actor,
    required this.description,
    required this.timestamp,
    this.iconType = '',
  });

  /// Returns a display emoji based on [iconType] or [type].
  ///
  /// This keeps emoji-mapping logic in the model layer so widgets
  /// remain presentation-only.
  String get emoji {
    final key = iconType.isNotEmpty ? iconType : type;
    switch (key) {
      case 'payment_added':
      case 'payment':
        return '💵';
      case 'photo_shared':
      case 'photo':
        return '📷';
      case 'document_uploaded':
      case 'document':
        return '📄';
      default:
        return '📌';
    }
  }

  /// Returns a human-readable relative time string from [timestamp].
  ///
  /// Example: "2h ago", "5h ago", "1d ago".
  /// Falls back to the raw timestamp if parsing fails.
  String get timeAgo {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return timestamp;
    }
  }

  /// Constructs the full display text combining actor and description.
  ///
  /// Example: "Ronit added ₹10000 for Hotel"
  String get displayText => '$actor $description';

  /// Parses an activity from the backend JSON map.
  ///
  /// Expected JSON shape:
  /// ```json
  /// {
  ///   "id": "activity1",
  ///   "type": "payment_added",
  ///   "actor": "Ronit",
  ///   "description": "added ₹10000 for Hotel",
  ///   "timestamp": "2026-03-10T10:00:00Z",
  ///   "iconType": "payment"
  /// }
  /// ```
  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      actor: json['actor'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      iconType: json['iconType'] as String? ?? '',
    );
  }

  /// Serializes this model back to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'actor': actor,
      'description': description,
      'timestamp': timestamp,
      'iconType': iconType,
    };
  }
}
