import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/image_merge_service.dart';
import '../../services/gallery_saver_android.dart';

class PreviewScreen extends StatefulWidget {
  final String imagePath;
  const PreviewScreen({super.key, required this.imagePath});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  int selectedFrame = 0;

  final List<String> frameList = [
    "assets/frames/frame1.png",
    "assets/frames/frame2.png",
    "assets/frames/frame3.png",
    "assets/frames/frame4.png",
    "assets/frames/frame5.png",
    "assets/frames/frame6.png",
  ];

  @override
  Widget build(BuildContext context) {
    final photoFile = File(widget.imagePath);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Preview"),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          /// -------------- MAIN IMAGE + FRAME -------------- ///
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.file(
                    photoFile,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: Image.asset(
                    frameList[selectedFrame],
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),

          /// -------------- FRAME PICKER -------------- ///
          Container(
            height: 120,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() => selectedFrame = index);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: index == selectedFrame
                            ? Colors.pink
                            : Colors.grey.shade300,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.asset(
                      frameList[index],
                      width: 70,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemCount: frameList.length,
            ),
          ),

          const SizedBox(height: 10),

          /// -------------- SAVE BUTTON -------------- ///
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final mergedFile = await ImageMergeService.mergePhotoWithFrame(
                    widget.imagePath,
                    frameList[selectedFrame],
                  );

                  // SAVE TO GALLERY VIA ANDROID NATIVE
                  final saved =
                      await GallerySaverAndroid.saveImageToGallery(mergedFile);

                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        saved
                            ? "Saved to Gallery!"
                            : "Failed to save image.",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
