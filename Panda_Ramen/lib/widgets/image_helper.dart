import 'dart:io';
import 'package:flutter/material.dart';

/// Membangun widget gambar yang otomatis mendeteksi jenis path gambar:
/// 1. URL internet (http/https)      -> Image.network
/// 2. Path file lokal hasil picker    -> Image.file
/// 3. Asset bawaan aplikasi           -> Image.asset
Widget buildMenuImage(
  String imagePath, {
  double width = 70,
  double height = 70,
  BoxFit fit = BoxFit.cover,
}) {
  Widget errorWidget() => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Icon(Icons.restaurant, color: Colors.grey),
      );

  if (imagePath.isEmpty) {
    return errorWidget();
  }

  final isNetwork =
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  if (isNetwork) {
    return Image.network(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => errorWidget(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[100],
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }

  // Path file lokal (hasil image_picker, disimpan di app documents directory).
  // Asset bawaan selalu diawali 'assets/', jadi path lain dianggap file lokal.
  final isAsset = imagePath.startsWith('assets/');

  if (!isAsset) {
    final file = File(imagePath);
    return Image.file(
      file,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => errorWidget(),
    );
  }

  return Image.asset(
    imagePath,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, __, ___) => errorWidget(),
  );
}
