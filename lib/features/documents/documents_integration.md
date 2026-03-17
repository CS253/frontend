# Documents — Backend Integration Guide

## Overview
The Documents feature manages trip-related documents (tickets, bookings, permits).

## Architecture
The Document management system enforces the **Feature-Based Clean Architecture** rules.
- Data flows strictly from `DocumentsScreen` → `DocumentProvider` (future) → `DocumentRepository` → `DocumentService` → `ApiClient`.

## Usage
- Models representing folders and files live inside `data/models/document_model.dart`.
- Any external UI looking to fetch or render the `Documents` feature should initialize `DocumentProvider` at the root of its scope.

## API Binding
The global `ApiClient` must be set up with HTTP endpoints for `/documents`. `DocumentService.dart` handles file uploads (e.g. `multipart/form-data`) completely ignoring UI states, and returning cleanly typed data mapped by repositories.

## API Endpoints

| Method | Endpoint          | Description              |
|--------|-------------------|--------------------------|
| GET    | `/documents`      | List all documents       |
| POST   | `/documents`      | Upload a new document    |
| DELETE | `/documents/:id`  | Delete a document        |

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
