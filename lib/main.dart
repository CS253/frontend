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
import 'package:flutter/foundation.dart'; // Add this for kIsWeb
import 'package:firebase_core/firebase_core.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with Web options if running on browser
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyATolWRkvu6vWXYD91aT4EkiDGfAHjND6s",
        authDomain: "travelly-66659.firebaseapp.com",
        projectId: "travelly-66659",
        storageBucket: "travelly-66659.firebasestorage.app",
        messagingSenderId: "545892068210",
        appId: "1:545892068210:web:4417af1baf13c370ac8beb",
        measurementId: "G-K4T7GRRY3V",
      ),
    );
  } else {
    // Android/iOS auto-picks up config files (google-services.json)
    await Firebase.initializeApp();
  }

  runApp(const App());
}
