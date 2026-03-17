import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/account_settings_provider.dart';
import '../widgets/profile_card.dart';
import '../widgets/setting_item.dart';
import '../widgets/settings_group.dart';
import 'personal_info_screen.dart';
import 'change_password_screen.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AccountSettingsProvider>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<AccountSettingsProvider>(
                builder: (context, provider, child) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

                          // Display Error if any
                          if (provider.errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                provider.errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),

                          ProfileCard(
                            userProfile: provider.userProfile,
                            isLoading: provider.isLoading,
                          ),
                          const SizedBox(height: 32),
                          _buildSectionHeader('APP OPTIONS'),
                          const SizedBox(height: 12),
                          SettingsGroup(
                            children: [
                              SettingItem(
                                title: 'Personal Information',
                                subtitle: 'Name, phone, address',
                                icon: Icons.person_outline,
                                iconBgColor: const Color(0xFFD9F0FC),
                                iconColor: const Color(0xFF333136),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const PersonalInfoScreen(),
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
                                subtitle: 'Toggle Alerts',
                                icon: Icons.notifications_none,
                                iconBgColor: const Color(0xFFE3D9F2),
                                iconColor: const Color(0xFF333136),
                                trailing: _buildSwitch(provider),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader('SECURITY'),
                          const SizedBox(height: 12),
                          SettingsGroup(
                            children: [
                              SettingItem(
                                title: 'Change Password',
                                subtitle: 'Update your password',
                                icon: Icons.lock_outline,
                                iconBgColor: const Color(0xFFD9F2EA),
                                iconColor: const Color(0xFF333136),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangePasswordScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SettingsGroup(
                            children: [
                              SettingItem(
                                title: 'Logout',
                                titleColor: const Color(0xFFAE9079),
                                subtitle: 'Sign out of your account',
                                icon: Icons.logout_outlined,
                                iconBgColor: const Color(0xFFF6EADB),
                                iconColor: const Color(0xFFAE9079),
                                showChevron: false,
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
          Container(
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
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Account Settings',
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

  Widget _buildSwitch(AccountSettingsProvider provider) {
    // If not loaded yet, use default false for switch
    final isEnabled = provider.userProfile?.notificationsEnabled ?? false;

    return Transform.scale(
      scale: 0.7,
      child: CupertinoSwitch(
        value: isEnabled,
        activeTrackColor: const Color(0xFF6BB5E5),
        onChanged: provider.isLoading
            ? null
            : (bool value) {
                provider.toggleNotifications(value);
              },
      ),
    );
  }
}
