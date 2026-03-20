# Trip Settings Integration

This document outlines the backend integration contract for the Trip Settings feature.

## Directory Structure
The `trip_settings` feature follows the Clean Architecture layout:
- `data/`
  - `models/`: Contains data transfer objects mapping JSON to Dart objects.
  - `services/`: Contains API services for making backend HTTP calls.
  - `repositories/`: Contains repository implementations to handle data caching and abstraction over services.
- `presentation/`
  - `providers/`: Contains state management using `ChangeNotifier` to feed data into UI.
  - `screens/`: Contains the actual UI.
  - `widgets/`: Contains reusable components.

## API Endpoints

### 1. Fetch Trip Members
**GET** `/trips/{tripId}/members`  
Retrieves the list of members for a specific trip, including their financial status.

#### Request Format
No request body. Requires `tripId` in path.

#### Response JSON
```json
{
  "data": [
    {
      "id": "u_1",
      "name": "Sarah Chen",
      "image_url": "https://ui-avatars.com/api/?name=Sarah+Chen",
      "is_admin": true,
      "status": "settled",
      "amount": 0,
      "phone": "+91 9876543210"
    },
    {
      "id": "u_2",
      "name": "Marcus Johnson",
      "image_url": "https://ui-avatars.com/api/?name=Marcus+Johnson",
      "is_admin": false,
      "status": "owes",
      "amount": 600
    }
  ]
}
```

### 2. Add Member to Trip
**POST** `/trips/{tripId}/members`  
Adds a new member using their phone number.

#### Request Format
```json
{
  "phone": "+91 9876543210"
}
```

#### Response JSON
```json
{
  "data": {
    "success": true,
    "member": {
      "id": "u_3",
      "name": "New User",
      "image_url": "...",
      "is_admin": false,
      "status": "settled",
      "amount": 0
    }
  }
}
```

### 3. Change Member Role (Make Admin)
**PATCH** `/trips/{tripId}/members/{userId}/role`  
Updates a member's role in the trip.

#### Request Format
```json
{
  "is_admin": true
}
```

### 4. Remove Member from Trip
**DELETE** `/trips/{tripId}/members/{userId}`  
Removes a member from the trip. Will fail if they have unsettled balances unless forced.

#### Request Format
*Optional parameter:* `?force=true` to remove even with pending balances.

#### Response JSON
```json
{
  "data": {
    "success": true
  }
}
```

### 5. Fetch Trip App Options (Settings)
**GET** `/trips/{tripId}/settings`  
Retrieves settings such as `simplify_expenses` and general trip info.

#### Response JSON
```json
{
  "data": {
    "id": "trip_123",
    "name": "The Lyaari Trip",
    "icon": "🏖️",
    "simplify_expenses": true
  }
}
```

### 6. Update Trip Settings
**PATCH** `/trips/{tripId}/settings`  
Toggle `simplify_expenses` or update currency.

#### Request Format
```json
{
  "simplify_expenses": false
}
```

### 7. Fetch Notification Preferences for Trip
**GET** `/trips/{tripId}/notifications`  
Gets the authenticated user's notification preferences for this specific trip.

#### Response JSON
```json
{
  "data": {
    "trip_alerts": true,
    "expense_split": true,
    "payment_reminders": true,
    "route_updates": false,
    "removal_notifications": false,
    "large_expenses": false
  }
}
```

### 8. Update Notification Preferences
**PATCH** `/trips/{tripId}/notifications`  

#### Request Format
```json
{
  "route_updates": true
}
```

---

## Integration Guide: What to replace and where?

### MOCK DATA REMOVAL & BACKEND HOOKUP

#### `lib/features/trip_settings/presentation/providers/trip_settings_provider.dart`
**Action Needed:**
1. Replace `_fetchMockMembers()` with `apiService.getTripMembers(tripId)`.
2. Replace local toggles `_tripAlerts = true` with actual `apiService.updateNotificationSettings(tripId, settings)`.
3. In `addMember(String phone)`, replace the `Future.delayed` mock insert with `apiService.addMember(tripId, phone)`.

#### `lib/features/trip_settings/presentation/screens/manage_members_screen.dart`
**Action Needed:**
1. Use `Consumer<TripSettingsProvider>` to build the list of members dynamically instead of the hardcoded `_buildMemberCard` and `_buildAdminCard` widgets.
2. In `_showAddMemberSheet()` on `ElevatedButton(onPressed: ...)`, call `context.read<TripSettingsProvider>().addMember(phoneController.text)`.
3. Inside `_showMemberOptions()`, implement real calls for `Make Admin` and `Remove from Trip`.

#### `lib/features/trip_settings/presentation/screens/trip_settings_screen.dart`
**Action Needed:**
1. Wrap the widget body with a `Consumer<TripSettingsProvider>` to read the `simplifyExpenses` boolean dynamically.
2. Replace local state variable `_simplifyExpenses` in `_buildSwitch`. The `onChanged` property should trigger `provider.updateTripSetting('simplify_expenses', value)`.
3. `_buildTripCard()` details ('The Lyaari Trip') should come from the provider.

#### `lib/features/trip_settings/presentation/screens/notification_settings_screen.dart`
**Action Needed:**
1. Wrap body in a `Consumer<TripSettingsProvider>`.
2. Replace all hardcoded state variables (`_tripAlerts`, `_expenseSplit`, etc.) with `provider.notificationSettings.tripAlerts`.
3. For each `CupertinoSwitch`'s `onChanged` method, call a provider method like `provider.updateNotificationSetting('trip_alerts', value)` to hit the backend right away.
