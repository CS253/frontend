// =============================================================================
// App Providers — Registers all providers for the application.
//
// This file creates and wires together the entire dependency chain:
//   ApiClient → Services → Repositories → Providers
//
// All providers are registered using MultiProvider at the app root.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Core
import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';

// Auth feature
import '../features/auth/data/services/auth_service.dart';
import '../features/auth/data/repositories/auth_repository.dart';
import '../features/auth/presentation/providers/auth_provider.dart';

// Trips feature
import '../features/trips/data/services/trips_service.dart';
import '../features/trips/data/repositories/trips_repository.dart';
import '../features/trips/presentation/providers/trips_provider.dart';

// Gallery feature
import '../features/gallery/data/repositories/photo_repository.dart';
import '../features/gallery/presentation/providers/gallery_provider.dart';

import '../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../features/dashboard/data/repositories/dashboard_repository.dart';
import '../features/dashboard/data/services/dashboard_service.dart';

// Account Settings feature
import '../features/account_settings/data/services/account_settings_service.dart';
import '../features/account_settings/data/repositories/account_settings_repository.dart';
import '../features/account_settings/presentation/providers/account_settings_provider.dart';

// Trip Settings feature
import '../features/trip_settings/data/services/trip_settings_api_service.dart';
import '../features/trip_settings/data/repositories/trip_settings_repository.dart';
import '../features/trip_settings/presentation/providers/trip_settings_provider.dart';

// Plan feature
import '../features/plan/data/services/plan_service.dart';
import '../features/plan/presentation/providers/plan_provider.dart';

/// Creates the shared ApiClient instance.
///
/// TODO: Update ApiEndpoints.baseUrl with real backend URL before deployment.
ApiClient createApiClient() {
  return ApiClient(baseUrl: ApiEndpoints.baseUrl);
}

/// Wraps the app with all required providers.
///
/// Usage in main.dart:
/// ```dart
/// runApp(
///   AppProviders.wrap(
///     child: const MyApp(),
///   ),
/// );
/// ```
class AppProviders {
  // Prevent instantiation
  AppProviders._();

  static Widget wrap({required Widget child}) {
    final apiClient = createApiClient();

    return MultiProvider(
      providers: [
        // -----------------------------------------------------------------------
        // Auth Feature Providers
        // -----------------------------------------------------------------------
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(
            repository: AuthRepository(
              service: AuthService(apiClient: apiClient),
              apiClient: apiClient,
            ),
          ),
        ),

        // -----------------------------------------------------------------------
        // Trips Feature Providers
        // -----------------------------------------------------------------------
        ChangeNotifierProvider<TripsProvider>(
          create: (_) => TripsProvider(
            repository: TripsRepository(
              service: TripsService(apiClient: apiClient),
            ),
          ),
        ),

        // -----------------------------------------------------------------------
        // Gallery Feature Providers
        // -----------------------------------------------------------------------
        ChangeNotifierProvider<GalleryProvider>(
          create: (_) => GalleryProvider(
            photoRepository: PhotoRepository(apiClient: apiClient),
          ),
        ),

        // -----------------------------------------------------------------------
        // Dashboard Feature Providers
        // Dependency chain: Provider → Repository → Service → ApiClient
        // -----------------------------------------------------------------------
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(
            repository: DashboardRepository(
              service: DashboardService(apiClient: apiClient),
            ),
          ),
        ),

        // -----------------------------------------------------------------------
        // Account Settings Feature Providers
        // -----------------------------------------------------------------------
        ChangeNotifierProvider<AccountSettingsProvider>(
          create: (_) => AccountSettingsProvider(
            AccountSettingsRepository(
              AccountSettingsService(apiClient),
            ),
          ),
        ),

        // -----------------------------------------------------------------------
        // Trip Settings Feature Providers
        // -----------------------------------------------------------------------
        ChangeNotifierProvider<TripSettingsProvider>(
          create: (_) => TripSettingsProvider(
            TripSettingsRepository(
              TripSettingsApiService(),
            ),
          ),
        ),

        // -----------------------------------------------------------------------
        // Plan Feature Providers
        // -----------------------------------------------------------------------
        ChangeNotifierProvider<PlanProvider>(
          create: (_) => PlanProvider(
            service: PlanService(apiClient: apiClient),
          ),
        ),
      ],
      child: child,
    );
  }
}
