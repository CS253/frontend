import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/photo_model.dart';
import '../../data/repositories/photo_repository.dart';

class GalleryProvider with ChangeNotifier {
  final PhotoRepository _photoRepository;

  GalleryProvider({required PhotoRepository photoRepository})
      : _photoRepository = photoRepository;

  List<Photo> _photos = [];
  Set<String> _selectedPhotoIds = {};
  bool _isLoading = false;
  String? _error;

  List<Photo> get photos => _photos;
  Set<String> get selectedPhotoIds => _selectedPhotoIds;
  bool get isSelectionMode => _selectedPhotoIds.isNotEmpty;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> pickAndUploadMedia() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultipleMedia();

      if (pickedFiles.isNotEmpty) {
        _isLoading = true;
        notifyListeners();

        for (var file in pickedFiles) {
          try {
            await _photoRepository.uploadPhoto(File(file.path));
          } catch (e) {
            // If an individual upload fails, continue with the rest
            debugPrint('Failed to upload ${file.name}: $e');
          }
        }

        // Refresh from server after uploads complete
        await fetchPhotos();
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
    try {
      await _photoRepository.deletePhoto(id);
      _photos.removeWhere((photo) => photo.id == id);
      _selectedPhotoIds.remove(id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete photo: $e';
      notifyListeners();
    }
  }

  Future<void> deleteSelected() async {
    try {
      final idsToDelete = _selectedPhotoIds.toList();
      await _photoRepository.deletePhotos(idsToDelete);
      _photos.removeWhere((photo) => idsToDelete.contains(photo.id));
      _selectedPhotoIds.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete photos: $e';
      notifyListeners();
    }
  }

  Future<void> fetchPhotos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedPhotos = await _photoRepository.fetchPhotos(page: 1, limit: 20);
      _photos = fetchedPhotos;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadPhoto(File image) async {
    try {
      await _photoRepository.uploadPhoto(image);
      await fetchPhotos(); 
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}

