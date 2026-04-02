import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/photo_model.dart';
import '../../data/repositories/photo_repository.dart';

class GalleryProvider with ChangeNotifier {
  final PhotoRepository _photoRepository;

  GalleryProvider({required PhotoRepository photoRepository})
    : _photoRepository = photoRepository;

  String? _currentGroupId;
  List<Photo> _photos = [];
  final Set<String> _selectedPhotoIds = {};
  bool _isLoading = false;
  String? _error;

  List<Photo> get photos => _photos;
  Set<String> get selectedPhotoIds => _selectedPhotoIds;
  bool get isSelectionMode => _selectedPhotoIds.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Allowed image extensions for gallery uploads.
  /// Videos are explicitly blocked.
  static const _allowedImageExtensions = {
    'jpg', 'jpeg', 'png', 'gif', 'heic', 'heif', 'webp', 'bmp',
  };

  /// Returns true if the file extension indicates an image (not a video).
  bool _isImageFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return _allowedImageExtensions.contains(ext);
  }

  Future<void> pickAndUploadMedia(String groupId) async {
    try {
      final ImagePicker picker = ImagePicker();
      // Use pickMultiImage instead of pickMultipleMedia to restrict to images only
      final List<XFile> pickedFiles = await picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        // Filter out any non-image files (safety net)
        final imageFiles = pickedFiles.where((f) => _isImageFile(f.path)).toList();
        final skippedCount = pickedFiles.length - imageFiles.length;

        if (skippedCount > 0) {
          debugPrint('GalleryProvider: Skipped $skippedCount non-image file(s). Only photos are allowed.');
        }

        if (imageFiles.isEmpty) {
          _error = 'Only photos are allowed. Videos cannot be uploaded.';
          notifyListeners();
          return;
        }

        _isLoading = true;
        notifyListeners();

        for (var file in imageFiles) {
          try {
            await _photoRepository.uploadPhoto(
              groupId: groupId,
              image: File(file.path),
            );
          } catch (e) {
            // If an individual upload fails, continue with the rest
            debugPrint('Failed to upload ${file.name}: $e');
          }
        }

        // Refresh from server after uploads complete
        await fetchPhotos(groupId);
      }
    } catch (e) {
      _error = 'Failed to pick media: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Selection Logic
  void toggleSelection(String id) {
    if (_selectedPhotoIds.contains(id)) {
      _selectedPhotoIds.remove(id);
    } else {
      _selectedPhotoIds.add(id);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedPhotoIds.clear();
    notifyListeners();
  }

  Future<void> deletePhoto(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _photoRepository.deletePhoto(id);
      _photos.removeWhere((photo) => photo.id == id);
      _selectedPhotoIds.remove(id);
    } catch (e) {
      _error = 'Failed to delete photo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSelected() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final idsToDelete = _selectedPhotoIds.toList();
      await _photoRepository.deletePhotos(idsToDelete);
      _photos.removeWhere((photo) => idsToDelete.contains(photo.id));
      _selectedPhotoIds.clear();
    } catch (e) {
      _error = 'Failed to delete photos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPhotos(String groupId) async {
    if (_currentGroupId != groupId) {
      _photos = [];
      _selectedPhotoIds.clear();
      _error = null;
    }
    _currentGroupId = groupId;
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedPhotos = await _photoRepository.fetchPhotos(
        groupId: groupId,
        page: 1,
        limit: 20,
      );
      _photos = fetchedPhotos;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadPhoto({
    required String groupId,
    required File image,
  }) async {
    try {
      await _photoRepository.uploadPhoto(groupId: groupId, image: image);
      await fetchPhotos(groupId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clears all gallery data (e.g., on logout).
  void clear() {
    _photos = [];
    _selectedPhotoIds.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
