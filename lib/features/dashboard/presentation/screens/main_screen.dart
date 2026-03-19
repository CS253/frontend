import 'package:flutter/material.dart';
import '../../../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../../../features/trip_settings/presentation/screens/trip_settings_screen.dart';
import '../../../../features/account_settings/presentation/screens/account_settings_screen.dart';
import '../../../../core/widgets/floating_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const TripSettingsScreen();
      case 2:
        return const AccountSettingsScreen();
      default:
        return const DashboardScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Or F9FAFC to match
      body: Stack(
        children: [
          // Background content changes with a nice fade transition
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_selectedIndex),
              child: _buildBody(),
            ),
          ),

          // Floating navbar overlaid on bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: FloatingNavbar(
              selectedIndex: _selectedIndex,
              onTabSelected: _onTabSelected,
            ),
          ),
        ],
      ),
    );
  }
}
