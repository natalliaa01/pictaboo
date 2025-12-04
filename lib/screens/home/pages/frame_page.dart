import 'package:flutter/material.dart';
import 'package:pictaboo/theme/app_theme.dart';
import '../frame_preview_page.dart'; // pastikan ada file ini ya

class FramePage extends StatelessWidget {
  const FramePage({super.key});

  static const List<String> framePaths = [
    "assets/frames/frame1.png",
    "assets/frames/frame2.png",
    "assets/frames/frame3.png",
    "assets/frames/frame4.png",
    "assets/frames/frame5.png",
    "assets/frames/frame6.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFBD1DC),
            Color(0xFFF5B7C6),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Choose Your Frame",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryPink,
                ),
              ),
            ),

            // === FRAMES GRID ===
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: framePaths.length,
                itemBuilder: (context, index) {
                  return _frameCard(context, framePaths[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _frameCard(BuildContext context, String path) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FramePreviewPage(framePath: path),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            path,
            fit: BoxFit.fitHeight,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
