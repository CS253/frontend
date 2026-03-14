// =============================================================================
// Main Entry Point — Travelly App
//
// Initializes the app with:
//   • MultiProvider wrapping (all providers registered in app_providers.dart)
//   • TravellyApp root widget (routes, theme configured in app.dart)
//
// Architecture: main.dart → AppProviders.wrap() → TravellyApp → Screens
// =============================================================================

import 'package:flutter/material.dart';
import 'app/app_providers.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    AppProviders.wrap(
      child: const TravellyApp(),
    ),
  );
}
