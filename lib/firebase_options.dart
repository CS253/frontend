import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyATolWRkvu6vWXYD91aT4EkiDGfAHjND6s',
    appId: '1:545892068210:web:4417af1baf13c370ac8beb',
    messagingSenderId: '545892068210',
    projectId: 'travelly-66659',
    authDomain: 'travelly-66659.firebaseapp.com',
    storageBucket: 'travelly-66659.firebasestorage.app',
    measurementId: 'G-K4T7GRRY3V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBb5o8xaPQUrWL9QKyDE1O7Zf9yGyXvzTk',
    appId: '1:545892068210:android:4a897759e8699698ac8beb',
    messagingSenderId: '545892068210',
    projectId: 'travelly-66659',
    storageBucket: 'travelly-66659.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4clpwCzE-DyucCtN9jQok8SE-3B0kH3o',
    appId: '1:545892068210:ios:70ed6f5c65be960fac8beb',
    messagingSenderId: '545892068210',
    projectId: 'travelly-66659',
    storageBucket: 'travelly-66659.firebasestorage.app',
    androidClientId: '545892068210-o9v4bg899bcse590tp7qmgftcc7lfs8a.apps.googleusercontent.com',
    iosClientId: '545892068210-bk9bfqdjsgbn1kqncd3k7ptrbm899gmq.apps.googleusercontent.com',
    iosBundleId: 'com.10bit.travelly',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC4clpwCzE-DyucCtN9jQok8SE-3B0kH3o',
    appId: '1:545892068210:ios:70ed6f5c65be960fac8beb',
    messagingSenderId: '545892068210',
    projectId: 'travelly-66659',
    storageBucket: 'travelly-66659.firebasestorage.app',
    iosBundleId: 'com.10bit.travelly',
  );
}