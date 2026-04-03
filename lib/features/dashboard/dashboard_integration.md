# Dashboard — Backend Integration Guide

## Overview

The Dashboard feature is the central navigation hub of the Travelly app. It displays:

- **Current Trip Header** — active trip name and location
- **Trip Info Card** — cover photo (or trip-type gradient), days remaining, emoji badge, participant avatars
- **Explore Grid** — 4 navigation cards (Payments, Gallery, Plan, Documents)
- **Recent Activity Feed** — chronological list of trip-related events

The frontend implementation is fully architected and currently operates on **mock data**. This document provides everything a backend developer needs to build the supporting API.

---

## API Endpoints

| Method | Endpoint              | Description                          | Auth Required |
|--------|-----------------------|--------------------------------------|---------------|
| GET    | `/dashboard`          | Fetch complete dashboard summary     | ✅ Yes         |
| GET    | `/dashboard/activity` | Fetch paginated recent activity list | ✅ Yes         |
| PUT    | `/trips/:id`          | Update trip details (all fields)     | ✅ Yes         |

### API Endpoint Constants (Flutter side)

Defined in `core/api/api_endpoints.dart`:

```dart
static const String dashboard = '/dashboard';
static const String recentActivity = '/dashboard/activity';
static String tripById(String id) => '/trips/$id';
```

---

## GET /dashboard

### Request

```http
GET /v1/dashboard
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Query Parameters (optional):**

| Param     | Type   | Description                                |
|-----------|--------|--------------------------------------------|
| `tripId`  | String | Specific trip ID (defaults to active trip)  |

### Response (200 OK)

```json
{
  "currentTrip": {
    "id": "trip123",
    "name": "The Lyaari Trip",
    "location": "Pakistan",
    "destination": "Lahore, Pakistan",
    "startDate": "2026-04-10",
    "endDate": "2026-04-20",
    "daysRemaining": 5,
    "emoji": "♠️",
    "tripType": "City",
    "coverImage": "https://storage.travelly.dev/covers/trip123.jpg",
    "participants": [
      {
        "id": "user1",
        "name": "Ronit",
        "avatarUrl": "https://storage.travelly.dev/avatars/user1.jpg",
        "emoji": "😊"
      },
      {
        "id": "user2",
        "name": "Sarim",
        "avatarUrl": "https://storage.travelly.dev/avatars/user2.jpg",
        "emoji": "😎"
      }
    ]
  },
  "recentActivities": [
    {
      "id": "activity1",
      "type": "payment_added",
      "actor": "Ronit",
      "description": "added ₹10000 for Hotel",
      "timestamp": "2026-03-10T10:00:00Z",
      "iconType": "payment"
    },
    {
      "id": "activity2",
      "type": "photo_shared",
      "actor": "Sarim",
      "description": "shared 12 photos",
      "timestamp": "2026-03-10T08:00:00Z",
      "iconType": "photo"
    },
    {
      "id": "activity3",
      "type": "document_uploaded",
      "actor": "Rigved",
      "description": "uploaded Flight Tickets",
      "timestamp": "2026-03-09T14:00:00Z",
      "iconType": "document"
    }
  ]
}
```

### Error Responses

| Status | Body                                          | When                        |
|--------|-----------------------------------------------|-----------------------------|
| 401    | `{ "message": "Unauthorized" }`               | Missing/invalid JWT token   |
| 404    | `{ "message": "No active trip found" }`       | User has no active trip     |
| 500    | `{ "message": "Internal server error" }`      | Unexpected server failure   |

---

## GET /dashboard/activity (Pagination)

### Request

```http
GET /v1/dashboard/activity?page=1&limit=10
Authorization: Bearer <jwt_token>
```

| Param   | Type | Default | Description                  |
|---------|------|---------|------------------------------|
| `page`  | int  | 1       | Page number (1-indexed)      |
| `limit` | int  | 10      | Items per page               |
| `tripId`| str  | active  | Filter by specific trip      |

### Response (200 OK)

```json
{
  "data": [
    {
      "id": "activity1",
      "type": "payment_added",
      "actor": "Ronit",
      "description": "added ₹10000 for Hotel",
      "timestamp": "2026-03-10T10:00:00Z",
      "iconType": "payment"
    }
  ],
  "meta": {
    "page": 1,
    "limit": 10,
    "total": 25,
    "hasMore": true
  }
}
```

---

## PUT /trips/:id (Update Trip Details)

Updates all editable trip fields from the Trip Details dialog.

### Request (JSON body — no cover photo change)

```http
PUT /v1/trips/trip123
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

```json
{
  "name": "The Lyaari Trip",
  "destination": "Lahore, Pakistan",
  "startDate": "2026-04-15",
  "endDate": "2026-04-25",
  "tripType": "City",
  "emoji": "✈️"
}
```

### Request (multipart/form-data — with cover photo upload)

```http
PUT /v1/trips/trip123
Authorization: Bearer <jwt_token>
Content-Type: multipart/form-data
```

| Field         | Type   | Description                            |
|---------------|--------|----------------------------------------|
| `name`        | String | Trip display name                      |
| `destination` | String | Trip destination                       |
| `startDate`   | String | ISO-8601 date (YYYY-MM-DD)             |
| `endDate`     | String | ISO-8601 date (YYYY-MM-DD)             |
| `tripType`    | String | Beach/Mountain/City/Nature/Island/Other|
| `emoji`       | String | Emoji identifier for badge             |
| `coverImage`  | File   | Cover photo file (jpg/jpeg/png, max 5MB)|

### Response (200 OK)

```json
{
  "status": "success",
  "trip": {
    "id": "trip123",
    "name": "The Lyaari Trip",
    "destination": "Lahore, Pakistan",
    "startDate": "2026-04-15",
    "endDate": "2026-04-25",
    "tripType": "City",
    "emoji": "✈️",
    "coverImage": "https://storage.travelly.dev/covers/trip123.jpg"
  }
}
```

### Error Responses

| Status | Body                                       | When                        |
|--------|--------------------------------------------|-----------------------------|
| 400    | `{ "message": "Invalid date format" }`     | Bad request body            |
| 400    | `{ "message": "End date must be after start date" }` | Date validation fails |
| 401    | `{ "message": "Unauthorized" }`            | Missing/invalid JWT token   |
| 403    | `{ "message": "Not a trip member" }`       | User lacks edit permission  |
| 404    | `{ "message": "Trip not found" }`          | Invalid trip ID             |

### Flutter Implementation

```
TripDetailsDialog (UI)
  → DashboardProvider.updateTrip()
    → DashboardRepository.updateTrip()
      → DashboardService.updateTrip()
        → ApiClient.put('/trips/:id')
```

---

## Database Entities

### `trips` Table

| Column       | Type      | Notes                          |
|--------------|-----------|--------------------------------|
| id           | UUID (PK) | Auto-generated                 |
| name         | VARCHAR   | Trip display name              |
| location     | VARCHAR   | Short location string          |
| destination  | VARCHAR   | Detailed destination string    |
| start_date   | DATE      | Trip start date                |
| end_date     | DATE      | Trip end date                  |
| trip_type    | VARCHAR   | Beach/Mountain/City/Nature/Island/Other |
| cover_image  | VARCHAR   | URL to uploaded cover photo (nullable) |
| emoji        | VARCHAR   | Emoji identifier for badge     |
| created_by   | UUID (FK) | References `users.id`          |
| created_at   | TIMESTAMP | Auto-generated                 |

### `trip_members` Table

| Column     | Type      | Notes                            |
|------------|-----------|----------------------------------|
| id         | UUID (PK) | Auto-generated                   |
| trip_id    | UUID (FK) | References `trips.id`            |
| user_id    | UUID (FK) | References `users.id`            |
| role       | ENUM      | "owner", "member"                |
| joined_at  | TIMESTAMP | Auto-generated                   |

### `activities` Table

| Column      | Type      | Notes                                     |
|-------------|-----------|-------------------------------------------|
| id          | UUID (PK) | Auto-generated                            |
| trip_id     | UUID (FK) | References `trips.id`                     |
| user_id     | UUID (FK) | Actor who performed the action            |
| type        | VARCHAR   | "payment_added", "photo_shared", etc.     |
| description | TEXT      | Human-readable action description         |
| icon_type   | VARCHAR   | "payment", "photo", "document"            |
| created_at  | TIMESTAMP | Used as `timestamp` in response           |

---

## Authentication Requirements

- All dashboard endpoints require a valid JWT Bearer token.
- The token identifies the user; the backend resolves the **active trip** for that user.
- Token is set in the Flutter `ApiClient` via `setAuthToken(token)`.

---

## Cover Photo Upload Flow

The cover photo can be uploaded during trip creation (POST /trips) or when editing via the Trip Details dialog (PUT /trips/:id).

### Upload Rules (Frontend Validation)
- **Allowed types**: jpg, jpeg, png
- **Max file size**: 5 MB
- **Upload method**: multipart/form-data

### Upload Flow
```
User taps "Cover Photo" → file_picker opens
  → User selects image from device
  → Frontend validates type & size
  → Image stored locally (preview shown)
  → On Save: sent as multipart/form-data to PUT /trips/:id
  → Backend stores file (e.g. S3/GCS) and returns coverImage URL
```

### Trip Info Card Display Logic

```
1. Custom Cover Photo: User-uploaded (network or local file)
2. Stock Photo Fallback: If no coverImage, system loads a high-quality 
   local asset based on tripType.
3. Gradient Fallback: If network images fail to load, a themed gradient
   is shown as a last resort.
```

### Stock Photo Fallback URLs

| Trip Type | Local Asset Fallback |
|-----------|-------------------------------|
| Beach     | `assets/images/Beach.png` |
| Mountain  | `assets/images/Mountain.png` |
| City      | `assets/images/City.png` |
| Nature    | `assets/images/Nature.png` |
| Island    | `assets/images/Island.png` |
| Other     | `assets/images/Other.png` |

### Dash of Premium UI (Glassmorphic Bar & Overlay)

Regardless of the background image, several premium UI elements ensure readability and consistency:
- **Dark Gradient Overlay**: A multi-stop black overlay (0% to 60% opacity) is applied at the card layer.
- **Backdrop Blur**: Destination pill and info bar use `ImageFilter.blur` for a frosted-glass effect.
- **Glassmorphic Objects**: Contain white text and icons with semi-transparent borders.

---

## Pagination Strategy (Activity Feed)

- Initial load: fetch first 10 activities via GET `/dashboard` (embedded in response).
- Load more: call GET `/dashboard/activity?page=2&limit=10`.
- The `meta.hasMore` boolean tells the client whether more pages exist.
- Flutter implementation can add infinite scroll by extending `DashboardProvider.fetchMoreActivities()`.

---

## Caching Strategy

- **Short TTL cache** (5 minutes) for the dashboard response — trip info rarely changes.
- **No cache** for activity feed — needs to be fresh on each visit.
- Cache invalidation: clear on pull-to-refresh or when user creates a new activity.
- Implementation: add a `_lastFetchTime` field to `DashboardProvider` and skip re-fetching if within TTL.

---

## Error Handling Strategy

| Layer        | Responsibility                                      |
|--------------|-----------------------------------------------------|
| `ApiClient`  | Throws `ApiException` for non-2xx responses         |
| `Service`    | Catches exceptions, falls back to mock data          |
| `Repository` | Parses JSON, propagates parsing errors               |
| `Provider`   | Catches all errors, sets `errorMessage` state        |
| `Screen`     | Displays error UI with retry button                  |

---

## Model ↔ Backend Response Mapping

| Flutter Model                | JSON Key                          | Type                     |
|------------------------------|-----------------------------------|--------------------------|
| `TripModel.id`               | `currentTrip.id`                  | String                   |
| `TripModel.name`             | `currentTrip.name`                | String                   |
| `TripModel.location`         | `currentTrip.location`            | String                   |
| `TripModel.destination`      | `currentTrip.destination`         | String                   |
| `TripModel.startDate`        | `currentTrip.startDate`           | String (ISO-8601 date)   |
| `TripModel.endDate`          | `currentTrip.endDate`             | String (ISO-8601 date)   |
| `TripModel.daysRemaining`    | `currentTrip.daysRemaining`       | int                      |
| `TripModel.emoji`            | `currentTrip.emoji`               | String                   |
| `TripModel.tripType`         | `currentTrip.tripType`            | String                   |
| `TripModel.coverImage`       | `currentTrip.coverImage`          | String (URL, nullable)   |
| `ParticipantModel.id`        | `participants[].id`               | String                   |
| `ParticipantModel.name`      | `participants[].name`             | String                   |
| `ParticipantModel.avatarUrl` | `participants[].avatarUrl`        | String (URL)             |
| `ActivityModel.id`           | `recentActivities[].id`           | String                   |
| `ActivityModel.type`         | `recentActivities[].type`         | String                   |
| `ActivityModel.actor`        | `recentActivities[].actor`        | String                   |
| `ActivityModel.description`  | `recentActivities[].description`  | String                   |
| `ActivityModel.timestamp`    | `recentActivities[].timestamp`    | String (ISO-8601)        |
| `ActivityModel.iconType`     | `recentActivities[].iconType`     | String                   |

---

## Data Flow Architecture

```
DashboardScreen (UI)
  → watches DashboardProvider (state management)
    → calls DashboardRepository (JSON → models)
      → calls DashboardService (HTTP + mock fallback)
        → calls ApiClient.get('/dashboard')
          → Backend API
```

---

## How to Remove Mock Data

After the backend is live and tested:

1. **`dashboard_service.dart`**: Delete the `_getMockDashboardData()` method and the fallback return in `fetchDashboard()`. Keep only the try block with `return response;`.

2. **Search for**: `MOCK DATA — DELETE AFTER BACKEND IS IMPLEMENTED` across all dashboard files to find every mock block.

3. **Test**: Run the app against the real backend and verify all dashboard sections render correctly.

4. **Remove emoji fallbacks**: Once avatar URLs are served by the backend, the `emoji` field on `ParticipantModel` can be deprecated.

---

## Flutter Files Reference

| Layer        | File                                                       |
|--------------|------------------------------------------------------------|
| Models       | `data/models/trip_model.dart`                              |
|              | `data/models/participant_model.dart`                       |
|              | `data/models/activity_model.dart`                          |
|              | `data/models/dashboard_response_model.dart`                |
| Service      | `data/services/dashboard_service.dart`                     |
| Repository   | `data/repositories/dashboard_repository.dart`              |
| Provider     | `presentation/providers/dashboard_provider.dart`           |
| Screen       | `presentation/screens/dashboard_screen.dart`               |
| Dialogs      | `presentation/dialogs/trip_details_dialog.dart`            |
| Widgets      | `presentation/widgets/trip_header.dart`                    |
|              | `presentation/widgets/participant_row.dart`                |
|              | `presentation/widgets/explore_grid.dart`                   |
|              | `presentation/widgets/explore_card.dart`                   |
|              | `presentation/widgets/activity_list.dart`                  |
|              | `presentation/widgets/activity_tile.dart`                  |
