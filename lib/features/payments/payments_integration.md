# Payments — Backend Integration Guide

## Overview
The Payments feature handles expense tracking, balance management, and settlement flows.

## API Endpoints

| Method | Endpoint              | Description           |
|--------|-----------------------|-----------------------|
| GET    | `/payments/expenses`  | List all expenses     |
| POST   | `/payments/expenses`  | Create new expense    |
| GET    | `/payments/balances`  | Get friend balances   |
| POST   | `/payments/settle`    | Settle a balance      |

## Data Flow

```
PaymentsScreen
  → PaymentProvider (future)
    → PaymentRepository
      → PaymentService → ApiClient
```

## Models

### `ExpenseModel`
```json
{
  "id": "abc123",
  "title": "Hotel Booking",
  "amount": 8000,
  "payer_name": "Ashish",
  "payer_initials": "AS",
  "payer_color": 10469322,
  "date": "Dec 20",
  "your_share": 500,
  "status": "Pending"
}
```

### `BalanceModel`
```json
{
  "id": "abc123",
  "name": "Ashish",
  "initials": "AS",
  "avatar_color": 10469322,
  "status_text": "You owe ₹500",
  "status_color": 16509420,
  "status_text_color": 13714526
}
```

### `MemberModel`
```json
{
  "id": "abc123",
  "initials": "AS",
  "name": "Ashish",
  "avatar_color": 10469322
}
```

## Steps to Integrate
1. Wire `PaymentRepository` methods to use `PaymentService`
2. Create `PaymentProvider` extending `ChangeNotifier`
3. Replace hardcoded data in screen/widgets with provider
4. Add real UPI deep-link integration in settle dialog
