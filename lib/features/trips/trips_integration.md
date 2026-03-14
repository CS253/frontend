# Trips Feature — Backend Integration Guide

## Overview

This document explains how the trips feature is structured for backend integration,
including validation rules, image upload flow, and backend trigger points.

---

## Validation Rules (Frontend)

All validation is performed client-side before any backend call is made.

### Trip Creation — Step 1 (Trip Details)
| Field | Validator | Rules |
|-------|-----------|-------|
| Trip Name * | `Validators.validateTripName` | Required, min 2 characters |
| Destination * | `Validators.validateDestination` | Required |
| Start Date * | Custom date validator | Required |
| End Date * | Custom date validator | Required, **must be after start date** |
| Trip Type * | Pre-selected | Required (default: Beach) |
| Cover Photo * | Optional | Image file from laptop (via file_picker) |

If end date is before or equal to start date, the error shown is:
**"End date must be after start date"**

### Trip Creation — Step 2 (Add Members)
| Field | Validator | Rules |
|-------|-----------|-------|
| Member Name * | `Validators.validateMemberName` | Required |
| Phone Number * | `Validators.validatePhone` | Required, valid phone format |

Members cannot be added if fields are empty or invalid.

### Implementation
- Steps 1 and 2 use separate `Form` widgets with `GlobalKey<FormState>`
- All fields use `TextFormField` with `validator` property
- Continue/Add buttons are BLOCKED until validation passes
- Date validation shows inline error message

### Date Selection UI Logic
To prevent the user from selecting an invalid date range:
1.  **Start Date**: Can be any future date.
2.  **End Date**: First date in the picker is restricted to the **selected Start Date**.
3.  **Visual Feedback**: All dates before the Start Date are **greyed out and unclickable** in the date picker using `selectableDayPredicate`.
4.  **Auto-Clear**: If the Start Date is changed to a date after the current End Date, the End Date is automatically cleared.

---

## Image Upload Flow

### Step 1: File Selection
1. User taps the "Cover Photo" upload area
2. `file_picker` package opens a native file dialog
3. **Type Validation**: Only `jpg`, `jpeg`, and `png` files are allowed.
4. **Size Validation**: Files must be **≤ 5 MB**.
5. Selected file path is stored in `_coverImagePath` (local state)
6. File path is also saved to `TripsProvider.newTripCoverImagePath`

### Step 2: Image Preview
1. Selected image is displayed using `Image.file()`
2. A "swap" button allows replacing the image
3. The review step (Step 3) also shows the selected image

### Step 3: Multipart Upload (Backend)
When "Create Trip" is pressed:

1. `TripsProvider.createTrip()` is called
2. `TripsRepository.createTrip()` passes the file path to the service
3. `TripsService.createTrip()` constructs a `multipart/form-data` request:

```dart
// Fields sent as form-data:
request.fields['name'] = name;
request.fields['destination'] = destination;
request.fields['startDate'] = startDate;
request.fields['endDate'] = endDate;
request.fields['tripType'] = tripType;

// Cover image sent as file:
request.files.add(
  await http.MultipartFile.fromPath('coverImage', coverImagePath),
);
```

### Backend Endpoint
```
POST /trips
Content-Type: multipart/form-data

Fields:
  - name: "Trip Name"
  - destination: "Destination"
  - startDate: "2024-05-01"
  - endDate: "2024-05-15"
  - tripType: "Beach"

File:
  - coverImage: <binary image data>
```

---

## Timeline Path Drawing

The curved path connecting trip cards in the **My Trips** dashboard is drawn dynamically.

### Implementation: `TripTimelinePainter`
- **Logic**: Calculates the centers of the trip nodes (images) based on the staggered layout.
- **Path**: Uses `path.cubicTo` to create a smooth S-curve between nodes.
- **Dynamic**: The path length and segments adjust automatically based on the number of trips in the list.
- **Coordinates**:
  - **Left Node**: `x = Margin + NodeRadius`, `y = Offset + (Index * Spacing) + NodeRadius`
  - **Right Node**: `x = ScreenWidth - Margin - NodeRadius`, `y = Offset + (Index * Spacing) + NodeRadius`

---

## Backend Trigger Points

Which UI action triggers which API call:

| UI Action | Provider Method | API Endpoint |
|-----------|---------------|-------------|
| MyTripsScreen loads | `TripsProvider.loadTrips()` | `GET /trips?page=1&limit=10` |
| Trip card tap | `TripsProvider.loadTripDetail()` | `GET /trips/{tripId}` |
| Create Trip → Create button | `TripsProvider.createTrip()` | `POST /trips` (multipart) |
| Add Member button | `TripsProvider.addMemberToNewTrip()` | Local state (added to POST /trips/{id}/members on create) |
| Members loaded | `TripsProvider.loadMembers()` | `GET /trips/{tripId}/members` |

---

## Data Flow

```
Screen (UI)
  → TripsProvider (state management)
    → TripsRepository (JSON → model conversion)
      → TripsService (HTTP calls)
        → ApiClient (base URL, headers, error handling)
          → Backend API
```

---

## API Endpoints

### GET /trips

**Query Params:** `?page=1&limit=10`

**Response (200):**
```json
{
  "trips": [
    {
      "id": "trip-001",
      "name": "Santorini Dreams",
      "destination": "Santorini, Greece",
      "coverImage": "https://storage.example.com/trips/trip-001/cover.jpg",
      "startDate": "2024-05-01",
      "endDate": "2024-05-15",
      "tripType": "Beach",
      "membersCount": 5,
      "createdBy": "user-001"
    }
  ],
  "total": 20,
  "page": 1,
  "limit": 10
}
```

### GET /trips/{tripId}

**Response (200):**
```json
{
  "trip": {
    "id": "trip-001",
    "name": "Santorini Dreams",
    "destination": "Santorini, Greece",
    "coverImage": "https://storage.example.com/trips/trip-001/cover.jpg",
    "startDate": "2024-05-01",
    "endDate": "2024-05-15",
    "tripType": "Beach",
    "membersCount": 5,
    "createdBy": "user-001"
  }
}
```

### POST /trips

**Content-Type:** `multipart/form-data`

**Fields:**
| Field | Type | Required |
|-------|------|----------|
| name | String | Yes |
| destination | String | Yes |
| startDate | String (ISO date) | Yes |
| endDate | String (ISO date) | Yes |
| tripType | String | Yes |
| coverImage | File | No |

**Response (201):**
```json
{
  "trip": {
    "id": "trip-new-123",
    "name": "Mountain Trek",
    "destination": "Swiss Alps",
    "coverImage": "https://storage.example.com/trips/trip-new-123/cover.jpg",
    "startDate": "2024-06-01",
    "endDate": "2024-06-10",
    "tripType": "Mountain",
    "membersCount": 0,
    "createdBy": "user-001"
  }
}
```

### POST /trips/{tripId}/members

**Request:**
```json
{
  "members": [
    { "name": "Alice", "phone": "+1234567890" },
    { "name": "Bob", "phone": "+0987654321" }
  ]
}
```

**Response (200):**
```json
{
  "members": [
    { "id": "member-001", "name": "Alice", "phone": "+1234567890", "role": "member" },
    { "id": "member-002", "name": "Bob", "phone": "+0987654321", "role": "member" }
  ]
}
```

### GET /trips/{tripId}/members

**Response (200):**
```json
{
  "members": [
    { "id": "member-001", "name": "Alice", "phone": "+1234567890", "role": "admin" },
    { "id": "member-002", "name": "Bob", "phone": "+0987654321", "role": "member" }
  ]
}
```

---

## Database Schema

```sql
CREATE TABLE trips (
  id           VARCHAR(36) PRIMARY KEY,
  name         VARCHAR(200) NOT NULL,
  destination  VARCHAR(200) NOT NULL,
  cover_image  VARCHAR(500),
  start_date   DATE NOT NULL,
  end_date     DATE NOT NULL,
  trip_type    VARCHAR(50) NOT NULL DEFAULT 'Beach',
  created_by   VARCHAR(36) NOT NULL REFERENCES users(id),
  created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CHECK (end_date > start_date)
);

CREATE TABLE trip_members (
  id        VARCHAR(36) PRIMARY KEY,
  trip_id   VARCHAR(36) NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  name      VARCHAR(100) NOT NULL,
  phone     VARCHAR(20),
  role      VARCHAR(20) NOT NULL DEFAULT 'member',
  added_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Error Response Format

```json
{
  "error": {
    "code": "TRIP_NOT_FOUND",
    "message": "Trip with the given ID does not exist"
  }
}
```

Common error codes:
- `TRIP_NOT_FOUND` — Trip ID doesn't exist
- `UNAUTHORIZED` — Not a member of the trip
- `VALIDATION_ERROR` — Server-side validation failed
- `FILE_TOO_LARGE` — Cover image exceeds size limit
- `INVALID_FILE_TYPE` — Uploaded file is not an image

---

## How to Connect Backend

1. Open `lib/features/trips/data/services/trips_service.dart`
2. Uncomment the `ApiEndpoints` import and `http` import
3. For each method:
   - Delete the mock data block (the one with `await Future.delayed(...)`)
   - Uncomment the real API call block below it
4. Update `lib/core/api/api_endpoints.dart` with real base URL
5. **No changes needed** in models, repositories, providers, or screens
