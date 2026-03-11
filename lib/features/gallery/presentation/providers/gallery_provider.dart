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

        // Normally, loop and call: await _photoRepository.uploadPhoto(File(file.path));

        // Mocking the successful upload response:
        for (var file in pickedFiles) {
          final newPhoto = Photo(
            id: DateTime.now().millisecondsSinceEpoch.toString() + file.name,
            imageUrl: '', // Blank since we use localPath directly
            localPath: file.path,
            authorName: 'You',
          );
          _photos.insert(0, newPhoto);
        }

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to pick media: \$e';
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

  void deletePhoto(String id) {
    // Like bulk delete, this removes locally. Usually calls repository.
    _photos.removeWhere((photo) => photo.id == id);
    _selectedPhotoIds.remove(id); // Ensure it's not held in selection state
    notifyListeners();
  }

  void deleteSelected() {
    // Usually this would call `_photoRepository.deletePhotos(_selectedPhotoIds)`
    // For now we just remove them locally from the _photos list to reflect the UI intent
    _photos.removeWhere((photo) => _selectedPhotoIds.contains(photo.id));
    _selectedPhotoIds.clear();
    notifyListeners();
  }

  Future<void> fetchPhotos() async {
    _isLoading = true;
    _error = null;
    // In a real app we would clear or append depending on pagination.
    // For now we just load the initial set of mock data.
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
      // After a successful upload, fetch the updated list or append locally
      await fetchPhotos(); 
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
