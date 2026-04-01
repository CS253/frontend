import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentDownloadService {
  final Dio _dio;

  DocumentDownloadService({Dio? dio}) : _dio = dio ?? Dio();

  /// Downloads a file to a user-visible location.
  ///
  /// - **iOS**: Saves to app Documents folder, visible in Files > On My iPhone > Travelly.
  /// - **Android**: Opens a folder picker so the user can choose where to save.
  /// - **Web**: Opens the URL in the browser for native download.
  Future<String?> downloadDocument(String url, String fileName) async {
    try {
      if (kIsWeb) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        return 'Browser Download';
      }

      String outputFile;

      if (Platform.isIOS) {
        // iOS: Save to the app's Documents directory.
        // With UIFileSharingEnabled + LSSupportsOpeningDocumentsInPlace in Info.plist,
        // this folder is visible in Files app > On My iPhone > Travelly.
        final dir = await getApplicationDocumentsDirectory();
        outputFile = '${dir.path}/$fileName';
      } else {
        // Android / Desktop: Let user pick a save location
        try {
          final selectedDirectory = await FilePicker.platform.getDirectoryPath(
            dialogTitle: 'Select where to save $fileName',
          );

          if (selectedDirectory == null) {
            return null; // User cancelled
          }
          outputFile = '$selectedDirectory/$fileName';
        } catch (e) {
          // Fallback if picker fails
          Directory? dir;
          if (Platform.isAndroid) {
            dir = await getExternalStorageDirectory();
            dir ??= await getApplicationDocumentsDirectory();
          } else {
            dir = await getDownloadsDirectory();
            dir ??= await getApplicationDocumentsDirectory();
          }
          if (dir == null) throw Exception('Could not determine download directory');
          outputFile = '${dir.path}/$fileName';
        }
      }

      // Download the file
      await _dio.download(
        url,
        outputFile,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint('Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      return outputFile;
    } catch (e) {
      debugPrint('Download Error: $e');
      throw Exception('Failed to download: $e');
    }
  }
}
