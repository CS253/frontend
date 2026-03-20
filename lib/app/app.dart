// =============================================================================
// App — Root widget for the Travelly application.
//
// Configures:
//   • Provider wrapping via AppProviders
//   • Theme using AppTheme
//   • Named routes via AppRoutes
//   • Initial route (Launch screen)
// =============================================================================

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/route_constants.dart';
import 'routes.dart';
import 'app_providers.dart';

class App extends StatelessWidget {
  final bool startFromTrips;

  const App({
    super.key,
    this.startFromTrips = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppProviders.wrap(
      child: MaterialApp(
        title: 'Travelly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: startFromTrips ? RouteConstants.trips : RouteConstants.launch,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
