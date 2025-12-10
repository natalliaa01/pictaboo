import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'project_detail_screen.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final supabase = Supabase.instance.client;

  List<dynamic> projects = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  Future<void> loadProjects() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final response = await supabase
        .from("projects")
        .select()
        .eq("user_id", user.id)
        .order("created_at", ascending: false);

    setState(() {
      projects = response;
      loading = false;
    });
  }

  // DELETE STORAGE + TABEL
  Future<void> deleteProject(dynamic row) async {
    final imageUrl = row["image_url"];
    final filePath = imageUrl.split("/projects/").last;

    // hapus di storage
    await supabase.storage.from("projects").remove([filePath]);

    // hapus row
    await supabase.from("projects").delete().eq("id", row["id"]);

    await loadProjects();
  }

  void confirmDelete(dynamic row) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Project"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteProject(row);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBD1DC),
      body: SafeArea(
        child:
            projects.isEmpty ? _buildEmpty() : _buildGrid(),
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
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
  return GridView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: projects.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.45, // lebih panjang supaya gambar tidak terlihat zoom
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
    ),
    itemBuilder: (context, index) {
      final item = projects[index];
      final imageUrl = item["image_url"];

      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(imageUrl: imageUrl),
            ),
          );
        },
        onLongPress: () => confirmDelete(item),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            imageUrl,
            fit: BoxFit.fitHeight, // gambar tidak akan ke-zoom
          ),
        ),
      );
    },
  );
}

}
