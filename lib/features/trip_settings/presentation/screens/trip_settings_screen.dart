import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travelly/features/account_settings/presentation/widgets/setting_item.dart';
import 'package:travelly/features/account_settings/presentation/widgets/settings_group.dart';
import 'package:travelly/core/widgets/glass_back_button.dart';
import '../providers/trip_settings_provider.dart';
import 'manage_members_screen.dart';
import 'notification_settings_screen.dart';

class TripSettingsScreen extends StatefulWidget {
  const TripSettingsScreen({super.key});

  @override
  State<TripSettingsScreen> createState() => _TripSettingsScreenState();
}

class _TripSettingsScreenState extends State<TripSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize with random trip ID. Change to actual tripId from arguments later
      context.read<TripSettingsProvider>().init('trip_123');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: Consumer<TripSettingsProvider>(
          builder: (context, provider, child) {
            
            // Build the switch state optimistically based on provider values
            final simplifyExpenses = provider.tripSettings?.simplifyExpenses ?? true;

            return Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          _buildTripCard(provider),
                          const SizedBox(height: 32),
                          _buildSectionHeader('APP OPTIONS'),
                          const SizedBox(height: 12),
                          SettingsGroup(
                            children: [
                              SettingItem(
                                title: 'Manage Members',
                                subtitle: 'Add/Remove Members',
                                icon: Icons.person_outline,
                                iconBgColor: const Color(0xFFD9F0FC),
                                iconColor: const Color(0xFF5AB6EE),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ManageMembersScreen(),
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                height: 1,
                                color: Color(0xFFEDEDED),
                                indent: 16,
                                endIndent: 16,
                              ),
                              SettingItem(
                                title: 'Notification Settings',
                                subtitle: 'Alerts, Splits...',
                                icon: Icons.notifications_none,
                                iconBgColor: const Color(0xFFE3D9F2),
                                iconColor: const Color(0xFF8757C3),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationSettingsScreen(),
                                    ),
                                  );
                                },
                              ),
                              const Divider(
                                height: 1,
                                color: Color(0xFFEDEDED),
                                indent: 16,
                                endIndent: 16,
                              ),
                              SettingItem(
                                title: 'Change Currency',
                                subtitle: 'Choose the currency for payments',
                                icon: Icons.payments_outlined,
                                iconBgColor: const Color(0xFFF8DA78),
                                iconColor: const Color(0xFFD3A117),
                                onTap: () {},
                              ),
                              const Divider(
                                height: 1,
                                color: Color(0xFFEDEDED),
                                indent: 16,
                                endIndent: 16,
                              ),
                              SettingItem(
                                title: 'Simplify Expenses',
                                subtitle: 'Reduce the number of transactions',
                                icon: Icons.account_tree_outlined, // close enough to the simplify graph
                                iconBgColor: const Color(0xFFD9F2EA),
                                iconColor: const Color(0xFF57C2A1),
                                trailing: _buildSwitch(
                                  simplifyExpenses,
                                  (value) => provider.updateTripSetting('simplify_expenses', value),
                                ),
                                showChevron: false,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Color(0xFFD74242),
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'DANGER ZONE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Nunito',
                                  color: Color(0xFFD74242),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SettingsGroup(
                            children: [
                              SettingItem(
                                title: 'Leave Trip',
                                titleColor: const Color(0xFFD74242),
                                subtitle: 'Leave this trip and its shared data',
                                icon: Icons.delete_outline,
                                iconBgColor: const Color(0xFFFDE8E8),
                                iconColor: const Color(0xFFD74242),
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDEDED), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          GlassBackButton(onPressed: () => Navigator.pop(context)),
          const SizedBox(width: 16),
          const Text(
            'Trip Settings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              color: Color(0xFF212022),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        fontFamily: 'Nunito',
        color: Color(0xFF8B8893),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTripCard(TripSettingsProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 38.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x33F09475), // rgba(240, 148, 117, 0.2)
            Color(0x0DF09475), // rgba(240, 148, 117, 0.05)
          ],
        ),
      ),
      child: Column(
        children: [
          if (provider.isLoadingTripSettings)
            const CircularProgressIndicator()
          else ...[
            Text(provider.tripSettings?.icon ?? '🏖️', style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 16),
            Text(
              provider.tripSettings?.name ?? 'Loading...',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Nunito',
                color: Color(0xFF212022),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return Transform.scale(
      scale: 0.7,
      child: CupertinoSwitch(
        value: value,
        activeTrackColor: const Color(0xFF6BB5E5),
        onChanged: onChanged,
      ),
    );
  }
}

