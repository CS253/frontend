# Gallery Feature Integration

## Overview
This document describes the Gallery feature according to the new clean feature-based architecture.

## Responsibilities
- **Data Layer (models, repositories, services):** Fetch photos from the backend API.
- **Presentation Layer (providers, screens, widgets):** Display shared albums and implement robust state management to handle loading, success, and error states.

## Integration Points
- Extends the `ApiClient` defined in `core/api/api_client.dart` for networking.
- Linked from the Dashboard section under "Explore".
- Fully encapsulated so external modules only depend on `gallery_screen.dart`.
