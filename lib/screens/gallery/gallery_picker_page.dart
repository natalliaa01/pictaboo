import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../result/photo_strip_page.dart';

class GalleryPickerPage extends StatefulWidget {
  final String framePath;

  const GalleryPickerPage({super.key, required this.framePath});

  @override
  State<GalleryPickerPage> createState() => _GalleryPickerPageState();
}

class _GalleryPickerPageState extends State<GalleryPickerPage> {
  final ImagePicker picker = ImagePicker();

  Future<void> pickImages() async {
    final images = await picker.pickMultiImage();

    if (images == null || images.isEmpty) {
      Navigator.pop(context);
      return;
    }

    // wajib 3 foto
    if (images.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select exactly 3 photos!")),
      );
      await Future.delayed(const Duration(milliseconds: 300));
      pickImages();
      return;
    }

    // ambil 3 foto pertama
    final threePaths = images.take(3).map((x) => x.path).toList();

    // KIRIM KE PHOTO STRIP
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoStripPage(
          framePath: widget.framePath,
          photos: threePaths,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    pickImages();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Opening gallery...")),
    );
  }
}
