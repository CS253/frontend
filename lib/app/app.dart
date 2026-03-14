// =============================================================================
// App — Root widget for the Travelly application.
//
// Configures:
//   • Theme using AppTheme
//   • Named routes via AppRoutes
//   • Initial route (Launch screen)
// =============================================================================

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/route_constants.dart';
import 'routes.dart';

class TravellyApp extends StatelessWidget {
  const TravellyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travelly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: RouteConstants.launch,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
