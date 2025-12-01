import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';
import '../frame_preview_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<String> sampleStrips = const [
    "assets/samples/sample1.jpg",
    "assets/samples/sample2.jpg",
    "assets/samples/sample3.jpg",
  ];

  final List<String> frames = const [
    "assets/frames/frame1.png",
    "assets/frames/frame2.png",
    "assets/frames/frame3.png",
    "assets/frames/frame4.png",
    "assets/frames/frame5.png",
    "assets/frames/frame6.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softPink1,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [

            const SizedBox(height: 20),

            // LOGO + TITLE
            Row(
              children: [
                Image.asset("assets/logo/logo.png", height: 40),
                const SizedBox(width: 10),
                Text(
                  "PICT A BOO",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    color: AppTheme.accentPurple,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // TITLE SECTION
            Text(
              "Photo Booth",
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentPurple,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              "Create fun photo strips!",
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 20),

            // START BUTTON
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: Text(
                  "Start",
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // SAMPLE STRIPS
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sampleStrips.length,
                separatorBuilder: (c, i) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      sampleStrips[index],
                      width: 130,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // CHOOSE FRAME TITLE
            Text(
              "Choose Frame",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentPurple,
              ),
            ),

            const SizedBox(height: 10),

            // FRAME GRID
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: frames.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.45,
              ),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FramePreviewPage(framePath: frames[index]),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(frames[index], fit: BoxFit.cover),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
