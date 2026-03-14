# Auth Feature — Backend Integration Guide

## Overview

This document explains how the auth feature is structured for backend integration.
All API calls flow through the provider → repository → service architecture.

---

## Validation Rules (Frontend)

All validation is performed client-side before any backend call is made.

### Login Screen
| Field | Validator | Rules |
|-------|-----------|-------|
| Email * | `Validators.validateEmail` | Required, valid email format |
| Password * | Inline validator | Required, cannot be empty |

### Register Screen
| Field | Validator | Rules |
|-------|-----------|-------|
| Email * | `Validators.validateEmail` | Required, valid email format |
| Phone Number * | `Validators.validatePhone` | Required, digits only, min 10 chars |

### OTP Screen
| Field | Validator | Rules |
|-------|-----------|-------|
| OTP * | `Validators.validateOtp` | Required, must be numeric, exactly 6 digits |

### Create Password Screen
| Field | Validator | Rules |
|-------|-----------|-------|
| Create Password * | `Validators.validatePassword` | Required, min 8 chars, at least 1 letter + 1 number |
| Confirm Password * | `Validators.validateConfirmPassword` | Required, must exactly match password field |

If passwords don't match, the error shown is: **"Passwords do not match"**

### Implementation
- All forms use `Form` widget with `GlobalKey<FormState>`
- All fields use `TextFormField` with `validator` property
- **UI Design**: Labels are NOT shown above fields. Instead, **Hint Text** is used inside the field (e.g., "Email", "Create Password").
- `autovalidateMode: AutovalidateMode.onUserInteraction` provides inline feedback
- Buttons are BLOCKED from proceeding until validation passes

---

## Backend Trigger Points

Which UI action triggers which API call:

| UI Action | Provider Method | API Endpoint |
|-----------|---------------|-------------|
| Login → Continue button | `AuthProvider.login()` | `POST /auth/login` |
| Register → Continue button | `AuthProvider.register()` | `POST /auth/register` |
| OTP → Continue button | `AuthProvider.verifyOtp()` | `POST /auth/verify-otp` |
| Create Password → Start Travelling button | `AuthProvider.createPassword()` | `POST /auth/create-password` |
| Google Sign-In button | `AuthProvider.googleSignIn()` | `POST /auth/google` |
| Logout button | `AuthProvider.logout()` | `POST /auth/logout` |

---

## Data Flow

```
Screen (UI)
  → AuthProvider (state management)
    → AuthRepository (JSON → model conversion)
      → AuthService (HTTP calls)
        → ApiClient (base URL, headers, error handling)
          → Backend API
```

---

## API Endpoints

### POST /auth/login

**Request:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": "user-001",
    "name": "John",
    "email": "user@example.com",
    "phone": "+1234567890"
  }
}
```

### POST /auth/register

**Request:**
```json
{
  "email": "newuser@example.com",
  "phone": "+1234567890"
}
```

**Response (200):**
```json
{
  "message": "OTP sent successfully",
  "tempToken": "temp-token-abc123"
}
```

### POST /auth/verify-otp

**Request:**
```json
{
  "otp": "123456",
  "tempToken": "temp-token-abc123"
}
```

**Response (200):**
```json
{
  "verified": true
}
```

### POST /auth/create-password

**Request:**
```json
{
  "password": "securepassword123",
  "confirmPassword": "securepassword123",
  "tempToken": "temp-token-abc123"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": "user-001",
    "name": "Traveller",
    "email": "newuser@example.com",
    "phone": "+1234567890"
  }
}
```

### POST /auth/google

**Request:**
```json
{
  "idToken": "google-oauth-id-token"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": "google-user-001",
    "name": "Google User",
    "email": "user@gmail.com"
  }
}
```

### POST /auth/logout

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "message": "Logged out successfully"
}
```

---

## Database Schema

```sql
CREATE TABLE users (
  id          VARCHAR(36) PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  email       VARCHAR(255) UNIQUE NOT NULL,
  phone       VARCHAR(20),
  password    VARCHAR(255) NOT NULL,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Error Response Format

All error responses should follow this format:

```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Email or password is incorrect"
  }
}
```

Common error codes:
- `INVALID_CREDENTIALS` — Wrong email/password
- `USER_EXISTS` — Email already registered
- `INVALID_OTP` — OTP expired or wrong
- `TOKEN_EXPIRED` — Temp token or JWT expired
- `VALIDATION_ERROR` — Server-side validation failed

---

## How to Connect Backend

1. Open `lib/features/auth/data/services/auth_service.dart`
2. Uncomment the `ApiEndpoints` import at line 12
3. For each method:
   - Delete the mock data block (the one with `await Future.delayed(...)`)
   - Uncomment the real API call block below it
4. Update `lib/core/api/api_endpoints.dart` with real base URL
5. **No changes needed** in models, repositories, providers, or screens
