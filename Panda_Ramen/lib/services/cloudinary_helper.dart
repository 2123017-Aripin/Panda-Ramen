import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CloudinaryHelper {
  // Ganti dengan data dari dashboard Cloudinary kamu
  static const String _cloudName = 'rjippwb8';
  static const String _uploadPreset = 'panda_ramen_upload';

  /// Upload gambar ke Cloudinary, kembalikan URL-nya
  static Future<String> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    // Kirim sebagai multipart request
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['public_id'] = 'menu_images/$fileName'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);
      return json['secure_url'] as String; // URL HTTPS gambar
    } else {
      final error = await response.stream.bytesToString();
      throw Exception('Upload gagal: $error');
    }
  }
}