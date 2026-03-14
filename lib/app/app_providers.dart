import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Feature Providers
import '../features/gallery/data/repositories/photo_repository.dart';
import '../features/gallery/presentation/providers/gallery_provider.dart';
import '../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../features/dashboard/data/repositories/dashboard_repository.dart';
import '../features/dashboard/data/services/dashboard_service.dart';
import '../core/api/api_client.dart';

/// Wraps the application with all necessary feature providers.
///
/// Each feature provider is registered here with its dependency chain.
/// Providers are lazily created — they only instantiate when first accessed.
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Core dependencies shared across features
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        // Gallery Feature
        ChangeNotifierProvider(
          create: (_) => GalleryProvider(
            photoRepository: PhotoRepository(apiClient: apiClient),
          ),
        ),

        // Dashboard Feature
        // Dependency chain: Provider → Repository → Service → ApiClient
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(
            repository: DashboardRepository(
              service: DashboardService(apiClient: apiClient),
            ),
          ),
        ),
      ],
      child: child,
    );
  }
}
