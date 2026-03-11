# Documents Feature Integration Guide

## Overview
This feature handles fetching and managing user documents.

## Architectural Layers

1. **Model** (`lib/features/documents/data/models/document_model.dart`)
2. **Service** (`lib/features/documents/data/services/document_service.dart`)
3. **Repository** (`lib/features/documents/data/repositories/document_repository.dart`)
4. **Provider** (`lib/features/documents/presentation/providers/document_provider.dart`)
5. **UI** (`lib/features/documents/presentation/screens/documents_screen.dart`, `widgets/document_card.dart`)

## API Endpoints
Base URL: Consult `lib/core/api/api_endpoints.dart`
- GET `/documents`: Fetch user documents
- POST `/documents/upload`: Upload a new document

## Backend Integration
1. Inject the Core `ApiClient` into `DocumentService`.
2. Connect real HTTP calls inside `ApiClient`.
3. Map JSON directly in `DocumentModel.fromJson()`.
