import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const photosBaseUrl = 'https://arewecookin-photos.areyouskurtz.workers.dev';

/// Uploads a post photo and returns its public URL (null when it failed).
abstract class PhotoUploader {
  Future<String?> upload(Uint8List bytes, String contentType);
}

class WorkerPhotoUploader implements PhotoUploader {
  @override
  Future<String?> upload(Uint8List bytes, String contentType) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token == null) return null;
      final res = await http.post(
        Uri.parse('$photosBaseUrl/upload'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': contentType},
        body: bytes,
      );
      if (res.statusCode != 200) return null;
      final key = (jsonDecode(res.body) as Map)['key'] as String?;
      return key == null ? null : '$photosBaseUrl/p/${Uri.encodeFull(key)}';
    } catch (_) {
      return null;
    }
  }
}
