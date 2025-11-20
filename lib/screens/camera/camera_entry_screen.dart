import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// CAMERA ENTRY SCREEN
/// - overlay frame (uses uploaded file as overlay)
/// - switch front/back camera
/// - timer (3..2..1) before capture when timer enabled
/// - capture 3 photos in sequence (auto-return to camera after each shot)
/// - after 3 photos -> navigate to FinalPreviewScreen (you will implement that next)
///
/// NOTE:
/// - This file uses an uploaded image file as overlay. Path to uploaded file:
///   '/mnt/data/28c7a94f-7b07-4ee3-a551-ce1cb87901a9.jpg'
///   (the environment will transform this local path to a URL when needed)
///
/// - Make sure camera permission is granted on device.
///
/// Usage:
/// Navigator.push(context, MaterialPageRoute(builder: (_) => CameraEntryScreen(forFrame: '/mnt/data/28c7a94f-7b07-4ee3-a551-ce1cb87901a9.jpg')));
class CameraEntryScreen extends StatefulWidget {
  final String? forFrame; // path to the frame overlay (can be asset or absolute path)
  const CameraEntryScreen({super.key, this.forFrame});

  @override
  State<CameraEntryScreen> createState() => _CameraEntryScreenState();
}

class _CameraEntryScreenState extends State<CameraEntryScreen> {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _selectedCameraIdx = 0;
  bool _isInitialized = false;

  // capture flow
  final List<String> _capturedPaths = [];
  int _targetCount = 3; // number of photos required by a frame (3 strip)
  int _currentIndex = 0;

  // timer
  bool _timerEnabled = false;
  int _countdown = 0;
  Timer? _countdownTimer;

  bool _isTakingPicture = false;

  // overlay path (uploaded file path)
  final String overlayPath = '/mnt/data/28c7a94f-7b07-4ee3-a551-ce1cb87901a9.jpg';

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        _selectedCameraIdx = 0;
        await _initController(_cameras[_selectedCameraIdx]);
      }
    } catch (e) {
      // ignore - show message in UI
      debugPrint('Camera init error: $e');
    }
  }

  Future<void> _initController(CameraDescription camera) async {
    _controller?.dispose();
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Controller init failed: $e');
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  void _switchCamera() async {
    if (_cameras.length < 2) return;
    _selectedCameraIdx = (_selectedCameraIdx + 1) % _cameras.length;
    await _initController(_cameras[_selectedCameraIdx]);
  }

  void _toggleTimer() {
    setState(() => _timerEnabled = !_timerEnabled);
  }

  void _startCountdownAndCapture() {
    if (_countdownTimer != null) return;
    setState(() {
      _countdown = 3; // 3 seconds countdown
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _countdownTimer = null;
        setState(() {
          _countdown = 0;
        });
        await _takePictureFlow();
      }
    });
  }

  Future<void> _takePictureFlow() async {
    if (_isTakingPicture) return;
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() => _isTakingPicture = true);

      // take picture
      final XFile file = await _controller!.takePicture();

      // move file to app temp dir with nicer name
      final tempDir = await getTemporaryDirectory();
      final dest = File('${tempDir.path}/pictaboo_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await File(file.path).copy(dest.path);

      _capturedPaths.add(dest.path);
      _currentIndex++;

      // brief flash / feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Captured ${_currentIndex}/$_targetCount')));
      }

      // if not done, continue (user must press capture again or we auto continue)
      // Here we return to camera view (so user can recompose). We'll not auto-capture next except when using timer.
      // You could auto-open timer again or show a quick animation.
      setState(() {
        _isTakingPicture = false;
      });

      // If reached target -> go to final preview flow
      if (_currentIndex >= _targetCount) {
        await Future.delayed(const Duration(milliseconds: 300));
        _goToFinalPreview();
      }
    } catch (e) {
      debugPrint('Take picture failed: $e');
      setState(() => _isTakingPicture = false);
    }
  }

  Future<void> _goToFinalPreview() async {
    // Navigate to FinalPreviewScreen - implement this screen to accept:
    // final framePath = widget.forFrame ?? overlayPath;
    // final imagePaths = _capturedPaths;
    //
    // Example:
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => FinalPreviewScreen(framePath, _capturedPaths)));
    //
    // For now we push a placeholder page showing thumbnails and a Save button.
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _FinalPreviewPlaceholder(
          framePath: widget.forFrame ?? overlayPath,
          imagePaths: List<String>.from(_capturedPaths),
        ),
      ),
    );
  }

  // User pressed primary capture button
  Future<void> _onCapturePressed() async {
    if (_timerEnabled) {
      _startCountdownAndCapture();
    } else {
      await _takePictureFlow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: SafeArea(
        child: Stack(
          children: [
            // CAMERA PREVIEW
            if (!_isInitialized)
              const Center(child: CircularProgressIndicator())
            else
              Positioned.fill(
                child: CameraPreview(_controller!),
              ),

            // OVERLAY (using uploaded file path) - semi transparent to help user compose
            if (widget.forFrame != null || overlayPath.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.9,
                    // If widget.forFrame is a file path, use Image.file; otherwise Image.asset fallback
                    child: widget.forFrame != null
                        ? Image.file(
                            File(widget.forFrame!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return const SizedBox.shrink();
                            },
                          )
                        : Image.file(
                            File(overlayPath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return const SizedBox.shrink();
                            },
                          ),
                  ),
                ),
              ),

            // Top controls (back, switch camera, timer toggle, thumbnails)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // back
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.7),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.pink),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  // center - thumbnails & counter
                  Column(
                    children: [
                      // captured thumbnails
                      Row(
                        children: List.generate(_targetCount, (i) {
                          final path = i < _capturedPaths.length ? _capturedPaths[i] : null;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 44,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: path != null
                                ? ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.file(File(path), fit: BoxFit.cover))
                                : const Center(child: Icon(Icons.photo_camera, color: Colors.white70)),
                          );
                        }),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_currentIndex}/$_targetCount',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  // right - switch camera and timer
                  Row(
                    children: [
                      // timer toggle
                      GestureDetector(
                        onTap: _toggleTimer,
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.7),
                          child: Icon(
                            Icons.timer,
                            color: _timerEnabled ? Colors.pink : Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // switch camera
                      if (_cameras.length > 1)
                        CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.7),
                          child: IconButton(
                            icon: const Icon(Icons.cameraswitch, color: Colors.pink),
                            onPressed: _switchCamera,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // countdown big number center
            if (_countdown > 0)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '$_countdown',
                    style: const TextStyle(fontSize: 72, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            // bottom controls (capture)
            Positioned(
              bottom: 18,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // small hint
                  const Text('Tap to capture - 3 photos', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // small icon left (gallery quick)
                      GestureDetector(
                        onTap: () async {
                          // TODO: implement quick gallery access (optional)
                        },
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.photo_library, color: Colors.pink[400]),
                        ),
                      ),
                      const SizedBox(width: 24),

                      // big capture button
                      GestureDetector(
                        onTap: _onCapturePressed,
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.pink.shade200, width: 6),
                          ),
                          child: Center(
                            child: _isTakingPicture
                                ? const CircularProgressIndicator()
                                : const Icon(Icons.camera_alt, color: Colors.pink, size: 32),
                          ),
                        ),
                      ),

                      const SizedBox(width: 24),

                      // flip camera small (redundant)
                      GestureDetector(
                        onTap: _switchCamera,
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.flip_camera_ios, color: Colors.pink[400]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple final preview placeholder - shows captured images and frame,
/// also offers Save button that should call merge & save service (we will implement final preview soon).
class _FinalPreviewPlaceholder extends StatelessWidget {
  final String framePath;
  final List<String> imagePaths;
  const _FinalPreviewPlaceholder({required this.framePath, required this.imagePaths, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preview Result'),
        backgroundColor: Colors.pink,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFBD1DC), Color(0xFFF5B7C6)]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // show thumbnails vertically (representing strip)
                      SizedBox(
                        width: 220,
                        child: Column(
                          children: List.generate(imagePaths.length, (i) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(imagePaths[i]), fit: BoxFit.cover, height: 120, width: 220),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text('Frame: ${framePath.split('/').last}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: call merge service & save to projects
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Save not yet implemented')));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
                        child: const Text('Save to Projects'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
