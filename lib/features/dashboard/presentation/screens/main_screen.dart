import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../../../features/documents/presentation/screens/documents_screen.dart';
import '../../../../features/gallery/presentation/screens/gallery_screen.dart';
import '../../../../features/payments/presentation/screens/payments_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  // Map indexes to arbitrary route names for the nested navigator
  final List<String> _routeNames = [
    '/',
    '/payments',
    '/plan',
    '/gallery',
    '/documents',
  ];

  /// Navigates to a specific tab by index.
  /// Uses the nested Navigator to push the new route with a sliding animation.
  void _navigateToTab(int index) {
    if (index == _selectedIndex) return;
    
    if (index >= 0 && index < _routeNames.length) {
      // If we are navigating TO home (index 0), we pop until home.
      // This helps prevent an infinitely deep navigation stack.
      if (index == 0) {
        _navigatorKey.currentState?.popUntil((route) => route.settings.name == '/');
      } else {
        _navigatorKey.currentState?.pushNamed(_routeNames[index]);
      }
      
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  /// Builds the screen requested by the nested Navigator route.
  Widget _getScreenForRoute(String routeName) {
    switch (routeName) {
      case '/':
        return DashboardScreen(onNavigate: _navigateToTab);
      case '/payments':
        return PaymentsScreen(onBackPressed: () => _navigateToTab(0));
      case '/plan':
        return const Scaffold(body: Center(child: Text('Plan')));
      case '/gallery':
        return GalleryScreen(onBackPressed: () => _navigateToTab(0));
      case '/documents':
        return DocumentsScreen(onBackPressed: () => _navigateToTab(0));
      default:
        return DashboardScreen(onNavigate: _navigateToTab);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We use PopScope to prevent returning to the Trip List screen
    // UNLESS the user is currently on the dashboard (index 0).
    // If they are deep in a nested route, we handle the back button 
    // to pop the nested route instead.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic result) async {
        if (didPop) return;

        final NavigatorState? navigator = _navigatorKey.currentState;
        if (navigator != null && navigator.canPop()) {
          // Inside a nested route -> pop the nested route
          navigator.pop();
        } else {
          // On the root route (Dashboard) -> allow system popping (back to Trips)
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Navigator(
          key: _navigatorKey,
          initialRoute: '/',
          onGenerateRoute: (settings) {
            final routeName = settings.name ?? '/';
            return CupertinoPageRoute(
              settings: settings,
              builder: (context) => _getScreenForRoute(routeName),
            );
          },
          // Important: Sync the BottomNavigationBar index when a 
          // nested route is popped (e.g., via iOS swipe back gesture).
          observers: [
            _NestedNavigatorObserver(
              onPopped: (route, previousRoute) {
                if (previousRoute != null && previousRoute.settings.name != null) {
                  final newIndex = _routeNames.indexOf(previousRoute.settings.name!);
                  if (newIndex != -1 && newIndex != _selectedIndex) {
                    // Schedule rebuild after the frame
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedIndex = newIndex);
                    });
                  }
                }
              },
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
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
        onTap: _navigateToTab,
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
                  color: _selectedIndex == 0 ? const Color(0xFFF3F3F3) : Colors.transparent,
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
                  color: _selectedIndex == 4 ? const Color(0xFFF3F3F3) : Colors.transparent,
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

/// Helper observer to synchronize the BottomNavigationBar 
/// when routes are popped (e.g. via swipe-back).
class _NestedNavigatorObserver extends NavigatorObserver {
  final void Function(Route<dynamic> route, Route<dynamic>? previousRoute) onPopped;

  _NestedNavigatorObserver({required this.onPopped});

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    onPopped(route, previousRoute);
  }
}
