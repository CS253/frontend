class NotificationSettingsModel {
  final bool tripAlerts;
  final bool expenseSplit;
  final bool paymentReminders;
  final bool routeUpdates;
  final bool removalNotifications;
  final bool largeExpenses;

  NotificationSettingsModel({
    required this.tripAlerts,
    required this.expenseSplit,
    required this.paymentReminders,
    required this.routeUpdates,
    required this.removalNotifications,
    required this.largeExpenses,
  });

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    // TODO: MOCK - When backend API returns actual notifications schema, replace the mapping here
    return NotificationSettingsModel(
      tripAlerts: json['trip_alerts'] as bool? ?? true,
      expenseSplit: json['expense_split'] as bool? ?? true,
      paymentReminders: json['payment_reminders'] as bool? ?? true,
      routeUpdates: json['route_updates'] as bool? ?? false,
      removalNotifications: json['removal_notifications'] as bool? ?? false,
      largeExpenses: json['large_expenses'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_alerts': tripAlerts,
      'expense_split': expenseSplit,
      'payment_reminders': paymentReminders,
      'route_updates': routeUpdates,
      'removal_notifications': removalNotifications,
      'large_expenses': largeExpenses,
    };
  }

  NotificationSettingsModel copyWith({
    bool? tripAlerts,
    bool? expenseSplit,
    bool? paymentReminders,
    bool? routeUpdates,
    bool? removalNotifications,
    bool? largeExpenses,
  }) {
    return NotificationSettingsModel(
      tripAlerts: tripAlerts ?? this.tripAlerts,
      expenseSplit: expenseSplit ?? this.expenseSplit,
      paymentReminders: paymentReminders ?? this.paymentReminders,
      routeUpdates: routeUpdates ?? this.routeUpdates,
      removalNotifications: removalNotifications ?? this.removalNotifications,
      largeExpenses: largeExpenses ?? this.largeExpenses,
    );
  }
}

class TripSettingsModel {
  final String id;
  final String name;
  final String icon;
  final bool simplifyExpenses;

  TripSettingsModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.simplifyExpenses,
  });

  factory TripSettingsModel.fromJson(Map<String, dynamic> json) {
    // TODO: MOCK - Parse standard trip model based on real API schema here structure
    return TripSettingsModel(
      id: json['id'] as String? ?? 't_000',
      name: json['name'] as String? ?? 'Trip Name',
      icon: json['icon'] as String? ?? '🏖️',
      simplifyExpenses: json['simplify_expenses'] as bool? ?? true,
    );
  }

  TripSettingsModel copyWith({
    String? id,
    String? name,
    String? icon,
    bool? simplifyExpenses,
  }) {
    return TripSettingsModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      simplifyExpenses: simplifyExpenses ?? this.simplifyExpenses,
    );
  }
}
