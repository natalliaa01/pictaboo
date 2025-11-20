import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

class ImageMergeService {
  static Future<File> mergePhotoWithFrame(
      String photoPath, String framePath) async {
    // Read photo
    final photoBytes = await File(photoPath).readAsBytes();
    img.Image photo = img.decodeImage(photoBytes)!;

    // Read frame
    final frameBytes = await File(framePath).readAsBytes();
    img.Image frame = img.decodeImage(frameBytes)!;

    // Resize frame to match photo
    img.Image resizedFrame = img.copyResize(
      frame,
      width: photo.width,
      height: photo.height,
    );

    // Merge using compositing
    final merged = img.Image(width: photo.width, height: photo.height);
    img.compositeImage(merged, photo);
    img.compositeImage(merged, resizedFrame);

    // Save output
    final outputPath = path.join(
      path.dirname(photoPath),
      "merged_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    final outputFile = File(outputPath);
    await outputFile.writeAsBytes(img.encodeJpg(merged, quality: 95));

    return outputFile;
  }
}
