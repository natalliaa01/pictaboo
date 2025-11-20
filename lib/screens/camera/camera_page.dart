import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../../../theme/app_theme.dart';
import '../result/photo_strip_page.dart';

class CameraPage extends StatefulWidget {
  final String framePath;
  const CameraPage({super.key, required this.framePath});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription> cameras = [];
  bool isFrontCamera = false;

  int timerValue = 0; // 0 = off, 3, 5 seconds
  int photoCount = 0;

  List<String> capturedPhotos = [];

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    startCamera(isFrontCamera ? cameras[1] : cameras[0]);
  }

  Future<void> startCamera(CameraDescription cameraDescription) async {
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> takePhoto() async {
    if (!controller!.value.isInitialized) return;

    // Jika timer aktif → tunggu sesuai detik
    if (timerValue > 0) {
      await Future.delayed(Duration(seconds: timerValue));
    }

    final image = await controller!.takePicture();

    final directory = await getTemporaryDirectory();
    final filePath =
        '${directory.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final newFile = await File(image.path).copy(filePath);

    capturedPhotos.add(newFile.path);
    photoCount++;

    if (photoCount == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PhotoStripPage(
            framePath: widget.framePath,
            photos: capturedPhotos,
          ),
        ),
      );
    } else {
      setState(() {});
    }
  }

  void switchCamera() {
    setState(() {
      isFrontCamera = !isFrontCamera;
    });
    startCamera(isFrontCamera ? cameras[1] : cameras[0]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softPink1,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 28,
                      color: AppTheme.primaryPink,
                    ),
                  ),
                  Row(
                    children: [
                      timerButton(0, "OFF"),
                      const SizedBox(width: 10),
                      timerButton(3, "3s"),
                      const SizedBox(width: 10),
                      timerButton(5, "5s"),
                    ],
                  ),
                  GestureDetector(
                    onTap: switchCamera,
                    child: const Icon(
                      Icons.cameraswitch,
                      size: 32,
                      color: AppTheme.primaryPink,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // CAMERA PREVIEW
            Expanded(
              child: controller == null || !controller!.value.isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : CameraPreview(controller!),
            ),

            const SizedBox(height: 10),

            // SHUTTER BUTTON
            GestureDetector(
              onTap: takePhoto,
              child: Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryPink,
                    width: 5,
                  ),
                ),
                child: Center(
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryPink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // TIMER BUTTON WIDGET
  Widget timerButton(int value, String label) {
    final isSelected = timerValue == value;
    return GestureDetector(
      onTap: () {
        setState(() => timerValue = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryPink : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.primaryPink),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.primaryPink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
