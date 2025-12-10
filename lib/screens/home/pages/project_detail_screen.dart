import 'package:flutter/material.dart';

class ProjectDetailScreen extends StatelessWidget {
  final String imageUrl;

  const ProjectDetailScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBD1DC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.pink,
        elevation: 0,
      ),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
