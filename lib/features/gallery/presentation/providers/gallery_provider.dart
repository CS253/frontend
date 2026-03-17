import 'package:flutter/foundation.dart';
import '../../data/models/photo_model.dart';
import '../../data/repositories/photo_repository.dart';

class GalleryProvider with ChangeNotifier {
  final PhotoRepository _repository;
  
  List<PhotoModel> _photos = [];
  bool _isLoading = false;
  String? _error;

  GalleryProvider(this._repository);

  List<PhotoModel> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPhotos(String tripId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _photos = await _repository.getPhotos(tripId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPhoto(String tripId, String url, String uploadedBy) async {
    try {
      final newPhoto = await _repository.addPhoto(tripId, url, uploadedBy);
      _photos.insert(0, newPhoto); // Insert at the start since it's the newest 
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
