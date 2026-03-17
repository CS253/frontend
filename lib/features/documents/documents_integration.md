# Documents — Backend Integration Guide

## Overview
The Documents feature manages trip-related documents (tickets, bookings, permits).

## API Endpoints

| Method | Endpoint          | Description              |
|--------|-------------------|--------------------------|
| GET    | `/documents`      | List all documents       |
| POST   | `/documents`      | Upload a new document    |
| DELETE | `/documents/:id`  | Delete a document        |

## Data Flow

```
DocumentsScreen
  → DocumentProvider (future)
    → DocumentRepository
      → DocumentService → ApiClient
```

## Model: `DocumentModel`
```json
{
  "id": "abc123",
  "emoji": "🚂",
  "title": "Train Ticket - Delhi to Pathankot",
  "subtitle": "Jan 15, 2024 · By Rahul"
}
```

## Steps to Integrate
1. Wire `DocumentRepository.getDocuments()` to use `DocumentService.fetchDocuments()`
2. Create `DocumentProvider` extending `ChangeNotifier`
3. Replace hardcoded list in `DocumentsScreen` with provider data
4. Add file upload support in `DocumentService`
