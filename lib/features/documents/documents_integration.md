# Documents Integration

## Architecture
The Document management system enforces the **Feature-Based Clean Architecture** rules.
- Data flows strictly from `DocumentScreen` -> `DocumentProvider` -> `DocumentRepository` -> `DocumentService` -> `ApiClient`.

## Usage
- Models representing folders and files live inside `data/models/document_model.dart`.
- Any external UI looking to fetch or render the `Documents` feature should initialize `DocumentProvider` at the root of its scope.

## API Binding
The global `ApiClient` must be set up with HTTP endpoints for `/documents`. `DocumentService.dart` handles file uploads (e.g. `multipart/form-data`) completely ignoring UI states, and returning cleanly typed data mapped by repositories.
