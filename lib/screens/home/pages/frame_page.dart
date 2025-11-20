import 'package:flutter/material.dart';

class FramePage extends StatelessWidget {
  const FramePage({super.key});

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
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              "Choose Your Frame",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 0.55,
              children: [
                _frameCard("assets/frames/frame1.png"),
                _frameCard("assets/frames/frame2.png"),
                _frameCard("assets/frames/frame3.png"),
                _frameCard("assets/frames/frame4.png"),
                _frameCard("assets/frames/frame5.png"),
                _frameCard("assets/frames/frame6.png"),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _frameCard(String path) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(path),
      ),
    );
  }
}
