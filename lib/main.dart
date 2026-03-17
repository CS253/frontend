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
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart';

// Set this to true to bypass auth flow and start directly on the My Trips screen
const bool kStartFromTrips = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for all platforms
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const App(startFromTrips: kStartFromTrips));
}
