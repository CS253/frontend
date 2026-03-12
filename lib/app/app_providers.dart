/// Top-level provider registration.
///
/// When adopting a state management solution (Provider, Riverpod, etc.),
/// wrap the app with MultiProvider / ProviderScope here.
///
/// Example with Provider:
/// ```dart
/// MultiProvider(
///   providers: [
///     ChangeNotifierProvider(create: (_) => PaymentProvider()),
///     ChangeNotifierProvider(create: (_) => DocumentProvider()),
///   ],
///   child: const MyApp(),
/// )
/// ```
class AppProviders {
  AppProviders._();
}
