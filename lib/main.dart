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
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/app.dart';

// Set this to true to bypass auth flow and start directly on the My Trips screen
const bool kStartFromTrips = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase for all platforms
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e is FirebaseException && e.code == 'duplicate-app') {
      // Firebase is already initialized on the native side
    } else {
      // Safe fallback if e is not FirebaseException or another error occurred
      if (e.toString().contains('duplicate-app')) {
        // Ignore duplicate app error
      } else {
        rethrow;
      }
    }
  }

  runApp(const App(startFromTrips: kStartFromTrips));
}
