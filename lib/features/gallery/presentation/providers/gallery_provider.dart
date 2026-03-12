import 'package:flutter/material.dart';
import '../../data/models/photo_model.dart';
import '../../data/repositories/photo_repository.dart';

class GalleryProvider with ChangeNotifier {
  final PhotoRepository repository;

  GalleryProvider({required this.repository});

  List<PhotoModel> _photos = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PhotoModel> get photos => _photos;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadPhotos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _photos = await repository.getPhotos();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
