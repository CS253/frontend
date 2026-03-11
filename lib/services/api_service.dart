import 'dart:convert';
import 'package:http/http.dart' as http; // Need to add http later if strictly required, but mock for now
import '../config/api_config.dart';

/// A service to interact with backend endpoints.
/// Currently configured with mock responses.
class ApiService {
  /// Simulates a GET request to fetch photos
  Future<Map<String, dynamic>> getPhotos({int page = 1, int limit = 20}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generating mock data that matches the Figma UI
    List<Map<String, dynamic>> mockData = [
      {
        'id': '1',
        'imageUrl': 'https://images.unsplash.com/photo-1503220317375-aaad61436b1b?q=80&w=600&auto=format&fit=crop', // Mountain
        'authorName': 'Rahul',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '2',
        'imageUrl': 'https://images.unsplash.com/photo-1506744626753-1fa28f673f0c?q=80&w=600&auto=format&fit=crop', // Lake and mountain
        'authorName': 'Priya',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '3',
        'imageUrl': 'https://images.unsplash.com/photo-1494500764479-0c8f2919a3d8?q=80&w=600&auto=format&fit=crop', // Landscape
        'authorName': 'Amit',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '4',
        'imageUrl': 'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?q=80&w=600&auto=format&fit=crop', // Nature
        'authorName': 'You',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '5',
        'imageUrl': 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?q=80&w=600&auto=format&fit=crop', // Forest
        'authorName': 'Rahul',
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '6',
        'imageUrl': 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?q=80&w=600&auto=format&fit=crop', // Mist
        'authorName': 'Priya',
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    return {
      'data': mockData,
      'meta': {
        'page': page,
        'limit': limit,
        'total': 6,
      }
    };
  }

  /// Simulates uploading an image
  Future<Map<String, dynamic>> uploadPhoto(String filePath) async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'status': 'success',
      'photo': {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'imageUrl': 'https://placehold.co/600x600/png',
        'authorName': 'You',
        'createdAt': DateTime.now().toIso8601String(),
      }
    };
  }
}
