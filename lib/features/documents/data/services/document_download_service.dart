import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DocumentDownloadService {
  final Dio _dio;

  DocumentDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  Future<String?> downloadDocument(String url, String fileName) async {
    try {
      Directory? dir;
      if (Platform.isAndroid) {
        // Try getting external storage for Android to make it visible to the user
        dir = await getExternalStorageDirectory();
        
        // If external storage is not available, fallback to application documents
        dir ??= await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      } else {
        dir = await getDownloadsDirectory();
      }

      if (dir == null) return null;

      String savePath = '${dir.path}/$fileName';
      
      await _dio.download(url, savePath);
      return savePath;
    } catch (e) {
      throw Exception('Failed to download document: $e');
    }
  }
}
