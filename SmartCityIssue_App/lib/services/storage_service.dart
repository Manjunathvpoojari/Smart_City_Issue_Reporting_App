import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

import '../core/constants.dart';
import 'supabase_service.dart';

class StorageService {
  final _client = SupabaseService.client;
  final _uuid = const Uuid();

  /// Compress and upload image, return public URL
  Future<String?> uploadIssueImage(File file) async {
    try {
      // Get file extension
      final ext = file.path.split('.').last.toLowerCase();
      final fileName = '${_uuid.v4()}.$ext';
      final filePath = 'issues/$fileName';

      // Try to compress first
      File uploadFile = file;
      try {
        final compressedPath = '${file.parent.path}/compressed_$fileName';
        final compressed = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          compressedPath,
          quality: 70,
          minWidth: 800,
          minHeight: 600,
        );
        if (compressed != null) {
          uploadFile = File(compressed.path);
        }
      } catch (e) {
        debugPrint('Compression skipped: $e');
        uploadFile = file; // use original if compression fails
      }

      // Upload using bytes (most compatible method)
      final bytes = await uploadFile.readAsBytes();

      await _client.storage
          .from(AppConstants.issueImagesBucket)
          .uploadBinary(filePath, bytes);

      // Get and return public URL
      final url = _client.storage
          .from(AppConstants.issueImagesBucket)
          .getPublicUrl(filePath);

      debugPrint('✅ Image uploaded: $url');
      return url;
    } catch (e) {
      debugPrint('IMAGE UPLOAD ERROR: ${e.runtimeType} → ${e.toString()}');
      return null;
    }
  }

  /// Delete image from storage
  Future<void> deleteImage(String url) async {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf(AppConstants.issueImagesBucket);
      if (bucketIndex != -1) {
        final path = segments.skip(bucketIndex + 1).join('/');
        await _client.storage
            .from(AppConstants.issueImagesBucket)
            .remove([path]);
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }
}
