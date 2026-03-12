import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Feature Providers
import '../features/gallery/data/repositories/photo_repository.dart';
import '../features/gallery/presentation/providers/gallery_provider.dart';
import '../core/api/api_client.dart';

/// Wraps the application with all necessary feature providers
class AppProviders extends StatelessWidget {
  final Widget child;

  const AppProviders({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Core dependencies can be initialized here
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        // Gallery Feature
        ChangeNotifierProvider(
          create: (_) => GalleryProvider(
            photoRepository: PhotoRepository(apiClient: apiClient),
          ),
        ),
        // Add more feature providers here (Documents, Dashboard, etc)
      ],
      child: child,
    );
  }
}
