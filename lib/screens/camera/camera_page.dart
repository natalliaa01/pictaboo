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

  int timerValue = 0; // 0 = off, 3, 5 seconds
  int photoCount = 0;

  List<String> capturedPhotos = [];
  Timer? countdownTimer;
  int countdown = 0; // Untuk menampilkan timer mundur di UI

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras available');
        return;
      }

      // kalau cuma 1 kamera, pakai itu saja
      final CameraDescription backCamera = cameras[0];
      final CameraDescription? frontCamera =
          cameras.length > 1 ? cameras[1] : null;

      startCamera(isFrontCamera && frontCamera != null ? frontCamera : backCamera);
    } catch (e) {
      debugPrint('initCamera error: $e');
    }
  }

  Future<void> startCamera(CameraDescription cameraDescription) async {
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,   // ← ganti ini
      enableAudio: false,
    );


    await controller!.initialize();
    if (mounted) setState(() {});
  }

  // Fungsi untuk memulai timer mundur
  void startTimer() {
    if (timerValue > 0) {
      countdown = timerValue;
      countdownTimer?.cancel(); // Hentikan timer yang sedang berjalan
      countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (countdown > 0) {
          setState(() {
            countdown--;
          });
        } else {
          countdownTimer?.cancel();
          takePhoto(); // Ambil foto setelah timer selesai
        }
      });
    }
  }

  Future<void> takePhoto() async {
    if (!controller!.value.isInitialized) return;

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
    if (cameras.length < 2) {
      // tidak ada kamera kedua, abaikan
      return;
    }
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

            // 👇👇 PREVIEW 3 FOTO (KOTAK HIJAU DI SS-MU) 👇👇
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  final hasPhoto = index < capturedPhotos.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: hasPhoto ? AppTheme.primaryPink : Colors.white,
                        width: 2,
                      ),
                    ),
                    child: hasPhoto
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(capturedPhotos[index]),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.photo_camera_outlined,
                            color: Colors.grey,
                          ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 10),
            // Timer Display
            if (timerValue > 0 && countdown > 0) 
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '$countdown',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPink,
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // 👇👇 CAMERA PREVIEW TIDAK GEPENG 👇👇
            SizedBox(
            // tinggi diset dari lebar, biar mirip XML 4:3
            height: MediaQuery.of(context).size.width * 3 / 4, // tinggi = lebar * (3/4)
            child: Center(
              child: controller == null || !controller!.value.isInitialized
                  ? const CircularProgressIndicator()
                  : AspectRatio(
                      aspectRatio: 4 / 3, // ⬅️ landscape: lebar > tinggi
                      child: CameraPreview(controller!),
                    ),
            ),
          ),



            const SizedBox(height: 10),

            // SHUTTER BUTTON
            GestureDetector(
              onTap: () {
                if (timerValue == 0) {
                  takePhoto();
                } else {
                  startTimer();
                }
              },
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
         setState(() {
          timerValue = value;
          countdown = value;  // Set countdown awal sesuai pilihan timer
        });
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
