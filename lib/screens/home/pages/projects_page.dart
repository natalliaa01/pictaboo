import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  List<String> savedProjects = [];

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('my_projects') ?? [];

    // filter: remove missing files
    final valid = data.where((p) => File(p).existsSync()).toList();

    setState(() {
      savedProjects = valid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBD1DC),
      body: SafeArea(
        child: savedProjects.isEmpty
            ? _buildEmpty()
            : _buildGrid(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_album_outlined,
              size: 80, color: Colors.pink.shade300),
          const SizedBox(height: 12),
          const Text(
            "No Projects Yet",
            style: TextStyle(
              fontSize: 22,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Your saved photo strips will appear here.",
            style: TextStyle(color: Colors.black45),
          )
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: savedProjects.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1 / 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final filePath = savedProjects[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProjectDetailScreen(filePath),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(filePath),
              fit: BoxFit.fitHeight,
            ),
          ),
        );
      },
    );
  }
}

class ProjectDetailScreen extends StatelessWidget {
  final String filePath;
  const ProjectDetailScreen(this.filePath, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBD1DC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.pink,
      ),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(filePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
