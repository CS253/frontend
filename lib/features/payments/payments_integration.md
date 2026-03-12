# Payments — Backend Integration Guide

## Overview
The Payments feature handles expense tracking, balance management, and settlement flows.

## API Endpoints

| GET    | `/payments/expenses`     | List all expenses     |
| POST   | `/payments/expenses`     | Create new expense    |
| DELETE | `/payments/expenses/{id}`| Delete an expense     |
| GET    | `/payments/balances`     | Get friend balances   |
| POST   | `/payments/settle`       | Settle a balance      |

## Data Flow

```
PaymentsScreen
  → PaymentProvider (future)
    → PaymentRepository
      → PaymentService → ApiClient
```

### `Create Expense Payload` (POST)
```json
{
  "amount": "19000",
  "description": "Flights",
  "emoji": "✈️",
  "payer": "Rushabh",
  "date": "29/02/2024",
  "transaction_id": "124421",
  "splits": [
    {"name": "Kashish", "amount": "9500"},
    {"name": "Rushabh", "amount": "9500"}
  ]
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
