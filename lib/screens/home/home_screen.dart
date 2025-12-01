import 'package:flutter/material.dart';

import 'pages/frame_page.dart';
import 'pages/projects_page.dart';
import 'pages/profile_page.dart';
import 'frame_preview_page.dart'; // kalau mau pakai nanti di _HomeContent

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeContent(
        onStartPressed: () {
          setState(() => currentIndex = 1); // pindah ke tab Frame
        },
      ),
      const FramePage(),
      const ProjectsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // FAB = langsung ke tab Frame juga
          setState(() => currentIndex = 1);
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
  final VoidCallback onStartPressed;

  const _HomeContent({
    super.key,
    required this.onStartPressed,
  });

  // 1 frame dulu, nanti bisa ditambah
  static const List<String> framePaths = [
    'assets/frames/frame1.png',
  ];

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
                        onPressed: onStartPressed, // ⬅️ langsung ke tab Frame
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

              // Example strips carousel (dummy)
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

              // Frames list: horizontal cards (pakai framePaths)
              SizedBox(
                height: 220,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: framePaths.length,
                  itemBuilder: (context, index) {
                    final framePath = framePaths[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                FramePreviewPage(framePath: framePath),
                          ),
                        );
                      },
                      child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white.withValues(alpha: 0.9),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
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
