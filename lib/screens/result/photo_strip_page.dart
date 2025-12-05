import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../../theme/app_theme.dart';
import '../../services/gallery_saver_android.dart';

// di atas file (di luar kelas) taruh ini:
const double kFrameAspectRatio = 0.35;
// contoh, nanti kamu sesuaikan


class PhotoStripPage extends StatefulWidget {
  final String framePath;
  final List<String> photos;

  const PhotoStripPage({
    super.key,
    required this.framePath,
    required this.photos,
  });

  @override
  State<PhotoStripPage> createState() => _PhotoStripPageState();
}

class _PhotoStripPageState extends State<PhotoStripPage> {
  final GlobalKey _captureKey = GlobalKey();
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softPink1,
      appBar: AppBar(
        title: const Text("Preview"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _captureKey,
                child: AspectRatio(
                  aspectRatio: kFrameAspectRatio, // pakai rasio frame
                  child: Stack(
                    children: [
                      // 3 FOTO DI BELAKANG FRAME
                      Column(
                        children: List.generate(3, (i) {
                          return Expanded(
                          child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: Image.file(
                                File(widget.photos[i]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }),
                      ),

                      // FRAME PNG DI ATASNYA
                      Positioned.fill(
                        child: Image.asset(
                          widget.framePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),


          const SizedBox(height: 20),

          // SAVE BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saving ? null : _saveResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // SLOT FOTO AMAN: KALAU INDEX DI LUAR RANGE, TAMPILIN PLACEHOLDER
  Widget _photoSlot(int index) {
    if (index >= widget.photos.length) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: Icon(Icons.photo, color: Colors.grey),
        ),
      );
    }

    return Image.file(
      File(widget.photos[index]),
      fit: BoxFit.cover,
    );
  }

  Future<void> _saveResult() async {
    setState(() => saving = true);

    try {
      final boundary = _captureKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Boundary not found');
      }

      final ui.Image image =
          await boundary.toImage(pixelRatio: 3.0); // high-res
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to encode image');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // SAVE TO TEMP FILE
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/strip_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      // SAVE TO GALLERY + MY PROJECTS
      final ok = await GallerySaverAndroid.saveImageToGallery(file);
      if (ok) {
        await GallerySaverAndroid.saveToMyProjects(file.path);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(ok ? "Saved to My Projects!" : "Failed to save"),
        ),
      );

      if (ok) Navigator.pop(context);
    } catch (e) {
      debugPrint("SAVE ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error while saving"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }
}
