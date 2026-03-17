# Gallery Integration

## Architecture
This feature follows the standard **Feature-Based Clean Architecture**:
1. `data/models/photo_model.dart` -> Parses JSON into fully-typed Dart models.
2. `data/services/photo_service.dart` -> Calls external APIs through the global `ApiClient`.
3. `data/repositories/photo_repository.dart` -> Abstracts API calls and manipulates models.
4. `presentation/providers/gallery_provider.dart` -> Stateholder interacting directly with the Repository.
5. `presentation/screens/gallery_screen.dart` -> Observes `GalleryProvider`.

## Backend Readiness
- All endpoints map via `photo_service`. Update `ApiClient` base endpoint during config.
- `PhotoModel` should be updated to match upcoming gallery schema from the backend.
