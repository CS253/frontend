# Dashboard — Backend Integration Guide

## Overview
The Dashboard feature displays trip information, explore navigation cards, and recent activity.

## API Endpoints

| Method | Endpoint             | Description                |
|--------|----------------------|----------------------------|
| GET    | `/dashboard`         | Fetch dashboard summary    |
| GET    | `/dashboard/activity`| Fetch recent activity list |

## Data Flow

```
DashboardScreen
  → DashboardProvider (future)
    → DashboardRepository
      → DashboardService → ApiClient.get('/dashboard')
```

## Models to Create

### `DashboardSummary`
```json
{
  "trip_name": "The Lyaari Trip",
  "starts_in_days": 5,
  "travelers": [...],
  "emoji": "♠️"
}
```

### `ActivityItem`
```json
{
  "id": "abc123",
  "emoji": "💵",
  "title": "Ronit added ₹10000 for Hotel",
  "created_at": "2026-03-12T14:30:00Z"
}
```

## Steps to Integrate
1. Create `data/models/dashboard_model.dart` with `fromJson`
2. Create `data/services/dashboard_service.dart` using `ApiClient`
3. Create `data/repositories/dashboard_repository.dart`
4. Create `presentation/providers/dashboard_provider.dart`
5. Replace hardcoded widgets with provider data
