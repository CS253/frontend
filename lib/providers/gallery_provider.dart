import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/photo.dart';
import '../repositories/photo_repository.dart';

class GalleryProvider with ChangeNotifier {
  final PhotoRepository _photoRepository;

  GalleryProvider({PhotoRepository? photoRepository})
      : _photoRepository = photoRepository ?? PhotoRepository();

  List<Photo> _photos = [];
  bool _isLoading = false;
  String? _error;

  List<Photo> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get error => _error;

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
