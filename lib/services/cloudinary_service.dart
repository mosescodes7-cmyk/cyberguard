import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../core/constants.dart';

class UploadedFile {
  const UploadedFile({required this.url, required this.thumbnailUrl});
  final String url;
  final String thumbnailUrl;
}

class CloudinaryException implements Exception {
  CloudinaryException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Unsigned uploads straight from the app to Cloudinary.
class CloudinaryService {
  static const int maxBytes = 25 * 1024 * 1024;

  Future<UploadedFile> upload({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/auto/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConfig.cloudinaryPreset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

    final streamed = await request.send().timeout(const Duration(minutes: 4));
    final res = await http.Response.fromStream(streamed);
    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {}

    if (res.statusCode != 200) {
      final msg = (data['error'] is Map)
          ? (data['error'] as Map)['message']?.toString()
          : null;
      throw CloudinaryException(msg ?? 'Upload failed (${res.statusCode}).');
    }

    final url = (data['secure_url'] ?? '').toString();
    if (url.isEmpty) throw CloudinaryException('Upload returned no file address.');
    final type = (data['resource_type'] ?? '').toString();
    final format = (data['format'] ?? '').toString().toLowerCase();

    var thumb = '';
    if (type == 'video') {
      thumb = url.replaceFirst(RegExp(r'\.[A-Za-z0-9]+$'), '.jpg');
    } else if (type == 'image' && format != 'pdf') {
      thumb = url;
    }
    return UploadedFile(url: url, thumbnailUrl: thumb);
  }
}
