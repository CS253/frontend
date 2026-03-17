import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:travelly/features/account_settings/presentation/widgets/setting_item.dart';
import 'package:travelly/features/account_settings/presentation/widgets/settings_group.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _tripAlerts = true;
  bool _expenseSplit = true;
  bool _paymentReminders = true;
  bool _routeUpdates = false;
  bool _removalNotifications = false;
  bool _largeExpenses = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF262F40).withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 3),
                spreadRadius: -3,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF212022),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            color: Color(0xFF212022),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFEDEDED), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NOTIFICATION TYPES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Nunito',
                  color: Color(0xFF8B8893),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              SettingsGroup(
                children: [
                  SettingItem(
                    title: 'Trip Alerts',
                    subtitle: 'Get notified about trip updates',
                    icon: Icons.notifications_none_outlined,
                    iconBgColor: const Color(0xFFD9F0FC),
                    iconColor: const Color(0xFF6BB5E5),
                    showChevron: false,
                    trailing: _buildSwitch(
                      _tripAlerts,
                      (val) => setState(() => _tripAlerts = val),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFEDEDED),
                    indent: 16,
                    endIndent: 16,
                  ),
                  SettingItem(
                    title: 'Expense Split Notifications',
                    subtitle: 'When someone adds or splits an expense',
                    icon: Icons.receipt_long_outlined,
                    iconBgColor: const Color(0xFFD9F2EA),
                    iconColor: const Color(0xFF57C2A1),
                    showChevron: false,
                    trailing: _buildSwitch(
                      _expenseSplit,
                      (val) => setState(() => _expenseSplit = val),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFEDEDED),
                    indent: 16,
                    endIndent: 16,
                  ),
                  SettingItem(
                    title: 'Payment Reminders',
                    subtitle: 'Reminders for pending payments',
                    icon: Icons.credit_card_outlined,
                    iconBgColor: const Color(0xFFFDE8D8),
                    iconColor: const Color(0xFFEB9559),
                    showChevron: false,
                    trailing: _buildSwitch(
                      _paymentReminders,
                      (val) => setState(() => _paymentReminders = val),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFEDEDED),
                    indent: 16,
                    endIndent: 16,
                  ),
                  SettingItem(
                    title: 'Route & Travel Updates',
                    subtitle: 'Real-time travel route changes',
                    icon: Icons.location_on_outlined,
                    iconBgColor: const Color(0xFFEBE0F5),
                    iconColor: const Color(0xFF8A5DB1),
                    showChevron: false,
                    trailing: _buildSwitch(
                      _routeUpdates,
                      (val) => setState(() => _routeUpdates = val),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFEDEDED),
                    indent: 16,
                    endIndent: 16,
                  ),
                  SettingItem(
                    title: 'Manage Removal notifications',
                    subtitle: 'Notify when someone is removed',
                    icon: Icons.campaign_outlined,
                    iconBgColor: const Color(0xFFF7DEE7),
                    iconColor: const Color(0xFFC65582),
                    showChevron: false,
                    trailing: _buildSwitch(
                      _removalNotifications,
                      (val) => setState(() => _removalNotifications = val),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFEDEDED),
                    indent: 16,
                    endIndent: 16,
                  ),
                  SettingItem(
                    title: 'Large Expenses alerts',
                    subtitle: 'Notify admin for expenses over ₹5,000',
                    icon: Icons.warning_amber_rounded,
                    iconBgColor: const Color(0xFFFDE8E8),
                    iconColor: const Color(0xFFD74242),
                    showChevron: false,
                    trailing: _buildSwitch(
                      _largeExpenses,
                      (val) => setState(() => _largeExpenses = val),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged) {
    return Transform.scale(
      scale: 0.75,
      child: CupertinoSwitch(
        value: value,
        activeTrackColor: const Color(0xFF6BB5E5),
        onChanged: onChanged,
      ),
    );
  }
}
