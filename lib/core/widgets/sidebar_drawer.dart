import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travelly/features/account_settings/presentation/providers/account_settings_provider.dart';
import 'package:travelly/features/account_settings/presentation/screens/account_settings_screen.dart';
import 'package:travelly/features/trip_settings/presentation/screens/trip_settings_screen.dart';

class SidebarDrawer extends StatelessWidget {
  const SidebarDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF9FAFC),
      surfaceTintColor: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Consumer<AccountSettingsProvider>(
                builder: (context, provider, child) {
                  final profile = provider.userProfile;
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF262F40,
                          ).withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD9F2EA),
                              width: 3,
                            ),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://ui-avatars.com/api/?name=Aditya+Sharma&background=random', // Placeholder
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile?.name ?? 'Aditya Sharma',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Nunito',
                                  color: Color(0xFF212022),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                profile?.email ?? 'aditya.sharma@email.com',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'Nunito',
                                  color: Color(0xFF8B8893),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  'APP OPTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: Color(0xFF8B8893),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF262F40).withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      iconBackgroundColor: const Color(0xFFD9F0FC),
                      iconColor: const Color(0xFF5AB6EE),
                      title: 'Account Settings',
                      subtitle: 'Name, phone, address',
                      showArrow: true,
                      onTap: () {
                        Navigator.pop(context); // close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountSettingsScreen(),
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
                    _buildMenuItem(
                      icon: Icons.business_center_outlined, // Briefcase
                      iconBackgroundColor: const Color(0xFFD9F2EA),
                      iconColor: const Color(0xFF57C2A1),
                      title: 'Trip Settings',
                      subtitle: 'Alerts, Splits...',
                      showArrow: true,
                      onTap: () {
                        Navigator.pop(context); // close drawer
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TripSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildDarkModeToggle(),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF262F40).withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildMenuItem(
                  icon: Icons.logout_outlined,
                  iconBackgroundColor: const Color(0xFFF6EADB),
                  iconColor: const Color(0xFFAE9079),
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  titleColor: const Color(0xFFAE9079),
                  showArrow: false,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color titleColor = const Color(0xFF212022),
    bool showArrow = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'Nunito',
                      color: Color(0xFF8B8893),
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFFC7C7CC),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkModeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE3D9F2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.nightlight_outlined,
                color: Color(0xFF8757C3), // Purple
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Nunito',
                      color: Color(0xFF212022),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your vibe, your theme',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Nunito',
                      color: Color(0xFF8B8893),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 24,
              width: 40,
              child: Switch(
                value: false,
                onChanged: (value) {},
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF90CDEF),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFCACCCE),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
