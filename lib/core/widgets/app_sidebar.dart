import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/route_constants.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Travelly App Sidebar (Drawer) — Sliding menu for trip-related options.
///
/// Designed based on Figma node 396:8202.
/// provides links to:
///   • Account Settings
///   • Trip Settings
///   • Logout
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile Header ─────────────────────────────────────────────
              _buildProfileHeader(user?.name ?? 'Traveller', user?.email ?? ''),
              const SizedBox(height: 32),

              // ── App Options Section ────────────────────────────────────────
              Text(
                'APP OPTIONS',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8B8893),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildOptionGroup(
                context,
                items: [
                  _SidebarItem(
                    icon: Icons.person_outline,
                    iconBgColor: const Color(0xFFD9F0FC),
                    iconColor: const Color(0xFF00A2FF),
                    title: 'Account Settings',
                    subtitle: 'Name, phone, address',
                    onTap: () => Navigator.of(context).pushNamed(RouteConstants.accountSettings),
                  ),
                  _SidebarItem(
                    icon: Icons.settings_outlined,
                    iconBgColor: const Color(0xFFF3F3F3),
                    iconColor: const Color(0xFF8B8893),
                    title: 'Trip Settings',
                    subtitle: 'Alerts, Splits...',
                    onTap: () => Navigator.of(context).pushNamed(RouteConstants.tripSettings),
                  ),
                ],
              ),
              const Spacer(),

              // ── Logout Section ─────────────────────────────────────────────
              const Divider(color: Color(0xFFEDEDED), height: 1),
              const SizedBox(height: 20),
              _buildSingleItem(
                _SidebarItem(
                  icon: Icons.logout_rounded,
                  iconBgColor: const Color(0xFFFBE9EC),
                  iconColor: const Color(0xFFAE9079),
                  title: 'Logout',
                  titleColor: const Color(0xFFAE9079),
                  subtitle: 'Sign out of your account',
                  onTap: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteConstants.login,
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.1),
            blurRadius: 23,
            offset: const Offset(0, 6),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with double border effect
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD9F2EA), width: 3),
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/signin_icon.png'), // Placeholder
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF212022),
                  ),
                ),
                Text(
                  email,
                  style: GoogleFonts.nunito(
                    fontSize: 11,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF8B8893),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionGroup(BuildContext context, {required List<_SidebarItem> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.1),
            blurRadius: 23,
            offset: const Offset(0, 6),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Column(
            children: [
              _buildSingleItem(item),
              if (index < items.length - 1)
                const Divider(color: Color(0xFFEDEDED), height: 1, indent: 56),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSingleItem(_SidebarItem item) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: item.iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(item.icon, size: 16, color: item.iconColor),
      ),
      title: Text(
        item.title,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: item.titleColor ?? const Color(0xFF212022),
        ),
      ),
      subtitle: Text(
        item.subtitle,
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF8B8893),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Color(0xFFBDBDBD)),
      onTap: item.onTap,
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final String subtitle;
  final VoidCallback onTap;

  _SidebarItem({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    this.titleColor,
    required this.subtitle,
    required this.onTap,
  });
}
