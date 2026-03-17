# Account Settings Integration

This document outlines the backend integration contract for the Account Settings feature.

## API Endpoints

### 1. Fetch User Profile
**GET** `/users/profile`  
Retrieves the profile information for the currently authenticated user.

#### Request Format
No query parameters required.

#### Response JSON
```json
{
  "data": {
    "id": "u_12345",
    "name": "Aditya Sharma",
    "email": "aditya.sharma@email.com",
    "phone": "+91 9876543210",
    "address": "123 Travelly Street, Mumbai, India",
    "image_url": "https://randomuser.me/api/portraits/men/32.jpg",
    "preferences": {
      "notifications_enabled": true
    }
  }
}
```

### 2. Update Notification Preferences
**PATCH** `/users/profile/preferences`  
Updates the user's notification preferences.

#### Request Format
```json
{
  "notifications_enabled": false
}
```

#### Response JSON
```json
{
  "data": {
    "notifications_enabled": false
  }
}
```

### 3. Update User Profile Details
**PATCH** `/users/profile`  
Updates basic details including the new UPI ID.

#### Request Format
```json
{
  "name": "Aditya Sharma",
  "email": "aditya.sharma@email.com",
  "phone": "+91 9876543210",
  "upi_id": "aditya.sharma@okicici"
}
```

#### Response JSON
```json
{
  "data": {
    "success": true
  }
}
```

### 4. Change Password
**POST** `/users/change-password`  
Changes the currently authenticated user's password securely.

#### Request Format
```json
{
  "current_password": "OldPassword123",
  "new_password": "NewStrongPassword456"
}
```

#### Response JSON
```json
{
  "data": {
    "success": true
  }
}
```

## Database Entities (Concept)

### UserProfile
- `id` (String)
- `name` (String)
- `email` (String)
- `phone` (String, nullable)
- `address` (String, nullable)
- `upi_id` (String, nullable)
- `image_url` (String, nullable)
- `preferences` (Map<String, dynamic>)

## Authentication
All endpoints require authentication:
`Authorization: Bearer <token>`

## Pagination Strategy
N/A - This screen primarily loads a single profile object.

## Error Handling
Standard error response format:
```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Authentication token is missing or invalid."
  }
}
```

## Caching Strategy
- **Fetch Profile**: Cache the `GET` response locally on first load.
- **Update Preferences**: Invalidate or forcefully update the cached user profile upon successful `PATCH`.

## Model Mapping
- **API JSON `/users/profile`** -> `UserProfile` model in Flutter.
- **API JSON `/users/profile/preferences`** -> Update relevant fields in `UserProfile` model and notify listeners in the `AccountSettingsProvider`.
