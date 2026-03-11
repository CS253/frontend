import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'documents_screen.dart';
import 'payments_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    DashboardScreen(onNavigate: _navigateTo),
    const PaymentsScreen(),
    const Scaffold(body: Center(child: Text('Plan'))),
    const Scaffold(body: Center(child: Text('Gallery'))),
    const DocumentsScreen(),
  ];

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 25.4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF00A2FF),
        unselectedItemColor: const Color(0xFF8B8893),
        selectedFontSize: 10,
        unselectedFontSize: 10,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: _selectedIndex == 0
                    ? const Color(0xFFD9F0FC).withValues(alpha: 0.54)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9.66),
                border: Border.all(
                  color: _selectedIndex == 0
                      ? const Color(0xFFF3F3F3)
                      : Colors.transparent,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: const Icon(Icons.home_outlined, size: 20),
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.payment_outlined, size: 20),
            ),
            label: 'Pay',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.map_outlined, size: 20),
            ),
            label: 'Plan',
          ),
          const BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.image_outlined, size: 20),
            ),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: _selectedIndex == 4
                    ? const Color(0xFFD9F0FC).withValues(alpha: 0.54)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(9.66),
                border: Border.all(
                  color: _selectedIndex == 4
                      ? const Color(0xFFF3F3F3)
                      : Colors.transparent,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              child: const Icon(Icons.description_outlined, size: 20),
            ),
            label: 'Docs',
          ),
        ],
      ),
    );
  }
}
