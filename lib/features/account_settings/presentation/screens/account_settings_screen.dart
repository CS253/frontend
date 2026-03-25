import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travelly/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelly/features/account_settings/data/models/user_profile.dart';
import 'package:travelly/core/constants/route_constants.dart';
import 'package:travelly/core/widgets/glass_back_button.dart';
import '../providers/account_settings_provider.dart';
import '../widgets/profile_card.dart';
import '../widgets/setting_item.dart';
import '../widgets/settings_group.dart';
import 'personal_info_screen.dart';
import 'change_password_screen.dart';
import '../../../trips/presentation/providers/trips_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../gallery/presentation/providers/gallery_provider.dart';
import '../../../trip_settings/presentation/providers/trip_settings_provider.dart';
import '../../../plan/presentation/providers/plan_provider.dart';

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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Consumer2<AccountSettingsProvider, AuthProvider>(
            builder: (context, provider, authProvider, child) {
              final firebaseUser = authProvider.user;
              final profile = provider.userProfile;

              // Use Firebase details if local profile is still loading or doesn't have them
              final displayEmail = firebaseUser?.email ?? profile?.email ?? 'Loading...';
              final displayName = profile?.name ?? firebaseUser?.name ?? 'Traveller';
              final displayImageUrl = profile?.imageUrl ?? firebaseUser?.avatarUrl;

              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 100,
                  bottom: 120, // space for navbar
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

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
                            userProfile: profile?.copyWith(
                              email: displayEmail,
                              name: displayName,
                              imageUrl: displayImageUrl,
                            ) ?? UserProfile(
                              id: '',
                              name: displayName,
                              email: displayEmail,
                              imageUrl: displayImageUrl,
                              phone: '',
                              address: '',
                              upiId: '',
                              notificationsEnabled: true,
                            ),
                            isLoading: provider.isLoading && profile == null,
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
                                 onTap: () async {
                                  // Clear all provider caches before logging out
                                  context.read<TripsProvider>().clearCache();
                                  context.read<DashboardProvider>().clear();
                                  context.read<GalleryProvider>().clear();
                                  context.read<AccountSettingsProvider>().clear();
                                  context.read<TripSettingsProvider>().clear();
                                  context.read<PlanProvider>().clearRoute();

                                  await authProvider.logout();
                                  if (context.mounted) {
                                    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                                      RouteConstants.login,
                                      (route) => false,
                                    );
                                  }
                                },
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: _buildHeader(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GlassBackButton(onPressed: () => Navigator.pop(context)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212022),
                  ),
                ),
              ),
            ],
          ),
        ),
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
