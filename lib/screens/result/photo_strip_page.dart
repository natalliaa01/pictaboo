import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../../theme/app_theme.dart';
import '../../services/gallery_saver_android.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// di atas file (di luar kelas) taruh ini:
// const double kFrameAspectRatio = 0.35;
const double kFrameAspectRatio = 707 / 2000;
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

// ukuran frame asli dalam pixel
static const double _frameHeightPx = 2000;

// tinggi 1 slot (PNG asli)
static const double _slotHeightPx = 656;

// posisi slot pertama dari atas (PNG asli)
static const double _slotTop1Px = -30;

// jarak antar slot (PNG asli → bisa kamu sesuaikan)
static const double _slotGapPx = -55;


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
  aspectRatio: kFrameAspectRatio,
  child: LayoutBuilder(
    builder: (context, constraints) {
      final renderHeight = constraints.maxHeight;

      // hitung skala PNG → device
      final scale = renderHeight / _frameHeightPx;

      final slotHeight = _slotHeightPx * scale;

      // hitung posisi slot 1,2,3 setelah diskalakan
      final slotTop1 = _slotTop1Px * scale;
      final slotTop2 = (_slotTop1Px + _slotHeightPx + _slotGapPx) * scale;
      final slotTop3 = (_slotTop1Px + 2 * _slotHeightPx + 2 * _slotGapPx) * scale;

      return Stack(
        children: [
          Positioned(
            left: 0, right: 0,
            top: slotTop1,
            height: slotHeight,
            child: _slot(widget.photos[0]),
          ),

          Positioned(
            left: 0, right: 0,
            top: slotTop2,
            height: slotHeight,
            child: _slot(widget.photos[1]),
          ),

          Positioned(
            left: 0, right: 0,
            top: slotTop3,
            height: slotHeight,
            child: _slot(widget.photos[2]),
          ),

          // frame PNG ditumpuk paling atas
          Positioned.fill(
            child: Image.asset(
              widget.framePath,
              fit: BoxFit.contain,
            ),
          ),
        ],
      );
    },
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

  Widget _slot(String path) {
    return ClipRect(
      child: Image.file(
        File(path),
        fit: BoxFit.cover,
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
    // ---- 1. RENDER IMAGE ----
    final boundary = _captureKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) throw Exception("Boundary not found");

    final ui.Image image =
        await boundary.toImage(pixelRatio: 3.0); // High resolution
    final byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) throw Exception("PNG encoding failed");

    final Uint8List pngBytes = byteData.buffer.asUint8List();

    // ---- 2. SAVE TO TEMP FILE ----
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/strip_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(pngBytes);

    // ---- 3. SAVE TO GALLERY (fungsi lama tetap berjalan) ----
    final galleryOk = await GallerySaverAndroid.saveImageToGallery(file);
    if (galleryOk) {
      await GallerySaverAndroid.saveToMyProjects(file.path);
    }

    // ---- 4. UPLOAD TO SUPABASE STORAGE ----
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception("Not logged in");

    final fileName =
        "strip_${user.id}_${DateTime.now().millisecondsSinceEpoch}.png";

    await Supabase.instance.client.storage
        .from("projects")
        .uploadBinary(
          fileName,
          pngBytes,
          fileOptions: const FileOptions(upsert: true),
        );

    // ---- 5. GET PUBLIC URL ----
    final publicUrl = Supabase.instance.client.storage
        .from("projects")
        .getPublicUrl(fileName);

    // ---- 6. INSERT RECORD KE SUPABASE TABLE `projects` ----
    await Supabase.instance.client.from("projects").insert({
      "user_id": user.id,
      "image_url": publicUrl,
    });

    // ---- 7. DONE FEEDBACK ----
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Saved to gallery & Supabase!")),
    );
  } catch (e) {
    debugPrint("SAVE ERROR: $e");

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

  } finally {
    if (mounted) setState(() => saving = false);
  }
}
}
