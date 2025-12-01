import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ImageMergeService {
  /// Merge 1 foto dengan 1 frame (bisa dari asset atau file path)
  static Future<File> mergePhotoWithFrame(
    String photoPath,
    String framePath,
  ) async {
    // ----- FOTO (selalu file) -----
    final photoBytes = await File(photoPath).readAsBytes();
    final img.Image? photo = img.decodeImage(photoBytes);
    if (photo == null) {
      throw Exception('Failed to decode photo image');
    }

    // ----- FRAME (bisa asset atau file) -----
    Uint8List frameBytes;
    if (framePath.startsWith('assets/')) {
      // load dari assets
      final data = await rootBundle.load(framePath);
      frameBytes = data.buffer.asUint8List();
    } else {
      // load dari file biasa
      frameBytes = await File(framePath).readAsBytes();
    }

    final img.Image? frame = img.decodeImage(frameBytes);
    if (frame == null) {
      throw Exception('Failed to decode frame image');
    }

    // ----- Resize frame ke ukuran foto -----
    final img.Image resizedFrame = img.copyResize(
      frame,
      width: photo.width,
      height: photo.height,
    );

    // ----- Compositing: foto dulu, frame di atas -----
    final img.Image merged = img.Image(
      width: photo.width,
      height: photo.height,
    );
    img.compositeImage(merged, photo);
    img.compositeImage(merged, resizedFrame);

    // ----- Simpan output -----
    final outputPath = path.join(
      path.dirname(photoPath),
      "merged_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(
      img.encodeJpg(merged, quality: 95),
    );

    return outputFile;
  }
}
