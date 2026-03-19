import 'dart:ui';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cupertino_native/cupertino_native.dart';

class FloatingNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const FloatingNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    bool isAppleNative = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

    if (isAppleNative) {
      return CNTabBar(
        items: [
          CNTabBarItem(
            label: 'Home',
            icon: const CNSymbol('house.fill'),
          ),
          CNTabBarItem(
            label: 'Trip Settings',
            icon: const CNSymbol('gearshape.fill'),
          ),
          CNTabBarItem(
            label: 'Profile',
            icon: const CNSymbol('person.fill'),
          ),
        ],
        currentIndex: selectedIndex,
        tint: const Color(0xFF00A2FF), // Travelly theme color
        height: 85,
        onTap: onTabSelected,
      );
    }

    // Original Android / Chrome (Web) Fallback
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Stack(
              children: [
                // ── Sliding Highlight Animation ──
                AnimatedAlign(
                  alignment: Alignment(
                    selectedIndex == 0
                        ? -1.0
                        : (selectedIndex == 1 ? 0.0 : 1.0),
                    0.0,
                  ),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCirc,
                  child: FractionallySizedBox(
                    widthFactor: 1 / 3, // Each tab takes exactly 1/3 of the width
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.25,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9F0FC).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Tab Items ──
                Row(
                  children: [
                    Expanded(
                      child: _NavBarItem(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        isSelected: selectedIndex == 0,
                        onTap: () => onTabSelected(0),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        icon: Icons.settings_outlined,
                        label: 'Trip Settings',
                        isSelected: selectedIndex == 1,
                        onTap: () => onTabSelected(1),
                      ),
                    ),
                    Expanded(
                      child: _NavBarItem(
                        icon: Icons.person_outline,
                        label: 'Profile',
                        isSelected: selectedIndex == 2,
                        onTap: () => onTabSelected(2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCirc,
        transformAlignment: Alignment.center,
        // ignore: deprecated_member_use
        transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 350),
              curve: !isSelected ? const Interval(0.0, 0.4) : const Interval(0.6, 1.0),
              opacity: isSelected ? 1.0 : 0.5,
              child: Icon(
                icon,
                size: 24,
                color: isSelected ? const Color(0xFF00A2FF) : const Color(0xFF8B8893),
              ),
            ),
            if (isSelected) const SizedBox(height: 2),
            if (isSelected)
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A2FF),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
