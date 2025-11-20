import 'package:flutter/material.dart';
import '../camera/camera_entry_screen.dart';
import 'pages/frame_page.dart';
import 'pages/projects_page.dart';
import 'pages/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  final pages = const [
    _HomeContent(),
    FramePage(),
    ProjectsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CameraEntryScreen()),
          );
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.camera_alt, color: Color(0xFFAE2A67)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        selectedItemColor: const Color(0xFFAE2A67),
        unselectedItemColor: Colors.grey.shade500,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Frame'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFBD1DC), Color(0xFFF5B7C6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: logo + title
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // replace with your logo asset at assets/logo/logo.png
                  Image.asset(
                    'assets/logo/logo.png',
                    width: 56,
                    height: 56,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'PICT A BOO',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B2B78),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // White rounded card (Title, subtitle, Start button)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Photo Booth',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B2A6A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Create fun photo strips!',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 140,
                      child: ElevatedButton(
                        onPressed: () {
                          // Start -> Scroll to frames or navigate to frames page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FramePage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2B7C5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Start',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Example strips carousel (horizontal)
              SizedBox(
                height: 150,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _exampleStrip('assets/welcome/sample_strip1.png'),
                    const SizedBox(width: 12),
                    _exampleStrip('assets/welcome/sample_strip2.png'),
                    const SizedBox(width: 12),
                    _exampleStrip('assets/welcome/sample_strip3.png'),
                    const SizedBox(width: 12),
                    _exampleStrip('assets/welcome/sample_strip4.png'),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              const Text(
                'Choose Frame',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B2A6A),
                ),
              ),

              const SizedBox(height: 12),

              // Frames list: horizontal cards (rounded pink background)
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    final framePath = 'assets/frames/frame${index + 1}.png';
                    return GestureDetector(
                      onTap: () {
                        // open review frame screen (next)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewFrameScreen(framePath),
                          ),
                        );
                      },
                      child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            framePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // graceful fallback when asset not found
                              return Container(
                                color: Colors.pink.shade50,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                    size: 36,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: 6,
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _exampleStrip(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.pink.shade50,
              child: const Center(
                child: Icon(Icons.photo, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Simple ReviewFrameScreen used by Home to move to review (matches "gambar 3")
class ReviewFrameScreen extends StatelessWidget {
  final String framePath;
  const ReviewFrameScreen(this.framePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Frame'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF8B2A6A),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFBD1DC), Color(0xFFF5B7C6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      framePath,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Container(
                        width: 220,
                        color: Colors.pink.shade50,
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Next → choose source (camera/gallery)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SelectSourceScreen(framePath),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFFFFF),
                      foregroundColor: const Color(0xFF8B2A6A),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: const BorderSide(color: Color(0xFFECC7D6)),
                    ),
                    child: const Text('Next'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Select source (camera or gallery) screen (matches "gambar 4")
class SelectSourceScreen extends StatelessWidget {
  final String framePath;
  const SelectSourceScreen(this.framePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Source'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF8B2A6A),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFBD1DC), Color(0xFFF5B7C6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  leading: const Icon(Icons.image, color: Color(0xFF8B2A6A)),
                  title: const Text("You're selecting 1 frame"),
                  subtitle: const Text("3 photos will be selected"),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/welcome/camera_illustration.png', width: 160, height: 160, errorBuilder: (_, __, ___) => const Icon(Icons.camera_alt, size: 80, color: Colors.pink)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // go to camera flow (3 photos)
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => CameraEntryScreen(forFrame: framePath)),
                              );
                            },
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Camera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF8B2A6A),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                          const SizedBox(width: 18),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: implement gallery multi-pick flow
                            },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Gallery'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF8B2A6A),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
