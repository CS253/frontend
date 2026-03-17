// =============================================================================
// App Routes — Centralized route definitions using named routes.
//
// All screen routes are registered here. Uses MaterialPageRoute for
// transition animations. Named routes enable type-safe navigation.
// =============================================================================

import 'package:flutter/material.dart';
import '../core/constants/route_constants.dart';

// Auth screens
import '../features/intro/presentation/screens/launch_screen.dart';
import '../features/intro/presentation/screens/sign_in_screen.dart';
import '../features/intro/presentation/screens/register_screen.dart';
import '../features/intro/presentation/screens/otp_screen.dart';
import '../features/intro/presentation/screens/google_sign_in_screen.dart';

// Trip screens
import '../features/trips/presentation/screens/my_trips_screen.dart';

import '../features/dashboard/presentation/screens/main_screen.dart';

// Settings screens
import '../features/account_settings/presentation/screens/account_settings_screen.dart';
import '../features/trip_settings/presentation/screens/trip_settings_screen.dart';
import '../features/account_settings/presentation/screens/personal_info_screen.dart';
import '../features/account_settings/presentation/screens/change_password_screen.dart';
import '../features/trip_settings/presentation/screens/manage_members_screen.dart';
import '../features/trip_settings/presentation/screens/notification_settings_screen.dart';

// Feature screens
import '../features/payments/presentation/screens/payments_screen.dart';
import '../features/gallery/presentation/screens/gallery_screen.dart';
import '../features/documents/presentation/screens/documents_screen.dart';

class AppRoutes {
  // Prevent instantiation
  AppRoutes._();

  /// Generates a route based on the route name.
  ///
  /// Usage in MaterialApp:
  /// ```dart
  /// MaterialApp(
  ///   onGenerateRoute: AppRoutes.generateRoute,
  ///   initialRoute: RouteConstants.launch,
  /// )
  /// ```
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Flow
      case RouteConstants.launch:
        return _buildRoute(const LaunchScreen(), settings);

      case RouteConstants.login:
        return _buildRoute(const SignInScreen(), settings);

      case RouteConstants.register:
        return _buildRoute(const RegisterScreen(), settings);

      case RouteConstants.verifyEmail:
        return _buildRoute(const OtpScreen(), settings);

      case RouteConstants.googleSignIn:
        return _buildRoute(const GoogleSignInScreen(), settings);

      // Trips
      case RouteConstants.trips:
        return _buildRoute(const MyTripsScreen(), settings);

      // Dashboard (main screen with bottom navigation)
      case RouteConstants.dashboard:
        return _buildRoute(const MainScreen(), settings);

      // Settings
      case RouteConstants.accountSettings:
        return _buildRoute(const AccountSettingsScreen(), settings);

      case RouteConstants.personalInfo:
        return _buildRoute(const PersonalInfoScreen(), settings);

      case RouteConstants.changePassword:
        return _buildRoute(const ChangePasswordScreen(), settings);

      case RouteConstants.tripSettings:
        return _buildRoute(const TripSettingsScreen(), settings);

      case RouteConstants.tripNotifications:
        return _buildRoute(const NotificationSettingsScreen(), settings);

      case RouteConstants.manageMembers:
        return _buildRoute(const ManageMembersScreen(), settings);

      // Features
      case RouteConstants.payments:
        return _buildRoute(const PaymentsScreen(), settings);

      case RouteConstants.gallery:
        return _buildRoute(const GalleryScreen(), settings);

      case RouteConstants.documents:
        return _buildRoute(const DocumentsScreen(), settings);

      // Default — 404
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  /// Builds a MaterialPageRoute with the given widget and settings.
  static MaterialPageRoute _buildRoute(Widget widget, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => widget,
      settings: settings,
    );
  }
}
