import 'dart:io';
import 'dart:async';
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

  int timerValue = 0;
  int countdown = 0;
  int photoCount = 0;

  List<String> capturedPhotos = [];
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final backCam = cameras[0];
    final frontCam = cameras.length > 1 ? cameras[1] : null;

    startCamera(isFrontCamera && frontCam != null ? frontCam : backCam);
  }

  Future<void> startCamera(CameraDescription cam) async {
    controller = CameraController(cam, ResolutionPreset.high, enableAudio: false);
    await controller!.initialize();
    if (mounted) setState(() {});
  }

  void startTimer() {
    countdown = timerValue;
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (countdown > 0) {
        setState(() => countdown--);
      } else {
        countdownTimer?.cancel();
        takePhoto();
      }
    });
  }

  Future<void> takePhoto() async {
    if (!controller!.value.isInitialized) return;

    final picture = await controller!.takePicture();
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final newFile = await File(picture.path).copy(filePath);
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
    if (cameras.length < 2) return;

    setState(() => isFrontCamera = !isFrontCamera);
    startCamera(isFrontCamera ? cameras[1] : cameras[0]);
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppTheme.softPink1,
    body: SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ---------------------------------------------------------
          // HEADER
          // ---------------------------------------------------------
          _buildHeader(),
          const SizedBox(height: 10),

          // ---------------------------------------------------------
          // PREVIEW 3 FOTO
          // ---------------------------------------------------------
          _buildPhotoPreviewStrip(),
          const SizedBox(height: 20),

          const SizedBox(height: 10),
           // Timer Display
            if (timerValue > 0 && countdown > 0) 
              Padding(
                padding: const EdgeInsets.all(0),
                child: Text(
                  '$countdown',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),


          // ---------------------------------------------------------
          // CAMERA PREVIEW
          // ---------------------------------------------------------
          Expanded(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: (MediaQuery.of(context).size.width * 0.9) * 3 / 4,
                child: controller == null || !controller!.value.isInitialized
                    ? const CircularProgressIndicator()
                    : AspectRatio(
                        aspectRatio: 4 / 3,
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: controller!.value.previewSize!.height,
                                height: controller!.value.previewSize!.width,
                                child: CameraPreview(controller!),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),


          // ---------------------------------------------------------
          // SHUTTER BUTTON
          // ---------------------------------------------------------
          _buildShutterButton(),
          const SizedBox(height: 30),
        ],
      ),
    ),
  );
}

  // -----------------------------------------------------------
  // UI COMPONENTS BELOW
  // -----------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _iconButton(Icons.arrow_back, () => Navigator.pop(context)),
          _timerSelector(),
          _iconButton(Icons.cameraswitch_rounded, switchCamera),
        ],
      ),
    );
  }

  Widget _iconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.9),
        ),
        child: Icon(icon, color: AppTheme.primaryPink, size: 26),
      ),
    );
  }

  Widget _timerSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppTheme.primaryPink),
      ),
      child: Row(
        children: [
          _timerButton(0, "OFF"),
          _timerButton(3, "3s"),
          _timerButton(5, "5s"),
        ],
      ),
    );
  }

  Widget _timerButton(int value, String label) {
    final selected = value == timerValue;
    return GestureDetector(
      onTap: () => setState(() {
        timerValue = value;
        countdown = value;
      }),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryPink : Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.primaryPink,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPreviewStrip() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final filled = i < capturedPhotos.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled ? AppTheme.primaryPink : Colors.white,
              width: 2,
            ),
          ),
          child: filled
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(capturedPhotos[i]), fit: BoxFit.cover),
                )
              : const Icon(Icons.photo_camera_outlined, color: Colors.grey),
        );
      }),
    );
  }

  Widget _buildCountdown() {
    return Text(
      "$countdown",
      style: const TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryPink,
      ),
    );
  }

  Widget _buildShutterButton() {
    return GestureDetector(
      onTap: () => timerValue == 0 ? takePhoto() : startTimer(),
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryPink, width: 6),
        ),
        child: Center(
          child: Container(
            width: 65,
            height: 65,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryPink,
            ),
          ),
        ),
      ),
    );
  }
}
