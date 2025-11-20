import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../../../theme/app_theme.dart';
import '../../services/gallery_saver_android.dart';

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

          // FINAL PREVIEW AREA
          Expanded(
            child: Center(
              child: RepaintBoundary(
                key: _captureKey,
                child: AspectRatio(
                  aspectRatio: 1 / 2.8,
                  child: Stack(
                    children: [
                      // 3 PHOTOS
                      Column(
                        children: [
                          Expanded(
                            child: Image.file(
                              File(widget.photos[0]),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Image.file(
                              File(widget.photos[1]),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Image.file(
                              File(widget.photos[2]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),

                      // OVERLAY FRAME PNG
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

  Future<void> _saveResult() async {
    setState(() => saving = true);

    try {
      // CAPTURE WIDGET TO IMAGE
      RenderRepaintBoundary boundary =
          _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      final pngBytes = byteData!.buffer.asUint8List();

      // SAVE TO TEMP FILE
      final dir = await getTemporaryDirectory();
      final file = File(
          '${dir.path}/strip_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      // SAVE TO GALLERY + MY PROJECTS
      final ok = await GallerySaverAndroid.saveImageToGallery(file);
      if (ok) {
        await GallerySaverAndroid.saveToMyProjects(file.path);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? "Saved to My Projects!" : "Failed to save"),
        ),
      );

      if (ok) Navigator.pop(context);
    } catch (e) {
      print("SAVE ERROR: $e");
    }

    setState(() => saving = false);
  }
}
