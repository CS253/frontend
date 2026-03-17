import 'package:flutter/material.dart';

class SettingItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final VoidCallback? onTap;
  final Color? titleColor;
  final Widget? trailing;
  final bool showChevron;

  const SettingItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.onTap,
    this.titleColor,
    this.trailing,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
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
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Icon(icon, size: 20, color: iconColor)),
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
                      color: titleColor ?? const Color(0xFF212022),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Nunito',
                      color: Color(0xFF8B8893),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron)
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF8B8893),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
