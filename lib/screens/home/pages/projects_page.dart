import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pictaboo/theme/app_theme.dart'; // Import AppTheme
import 'package:pictaboo/screens/home/pages/project_detail_screen.dart';

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
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final response = await supabase
          .from("projects")
          .select()
          .eq("user_id", user.id)
          .order("created_at", ascending: false);

      if (mounted) {
        setState(() {
          projects = response;
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading projects: $e");
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> deleteProject(dynamic row) async {
    try {
      final imageUrl = row["image_url"] as String;
      final filePath = imageUrl.split("/projects/").last;
      await supabase.storage.from("projects").remove([filePath]);
      await supabase.from("projects").delete().eq("id", row["id"]);
      await loadProjects();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project berhasil dihapus")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menghapus: $e")),
        );
      }
    }
  }

  void confirmDelete(dynamic row) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Hapus Project?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppTheme.accentPurple)),
        content: Text("Foto ini akan dihapus permanen.", style: GoogleFonts.poppins()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Batal", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await deleteProject(row);
            },
            child: Text("Hapus", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softPink1, // Background Pink Lembut
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // HEADER YANG SERAGAM DENGAN PROFILE PAGE
            Text(
              "My Projects",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryPink, // Warna Pink Tua Elegan
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryPink))
                  : projects.isEmpty
                      ? _buildEmpty()
                      : _buildGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 80, color: AppTheme.primaryPink.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            "Belum ada project tersimpan",
            style: GoogleFonts.poppins(color: AppTheme.accentPurple, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return RefreshIndicator(
      onRefresh: loadProjects,
      color: AppTheme.primaryPink,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding kiri kanan biar rapi
        itemCount: projects.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55, 
          crossAxisSpacing: 16, // Jarak antar item lebih lega
          mainAxisSpacing: 16,
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Frame putih biar elegan
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentPurple.withOpacity(0.1), // Shadow ungu tipis
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: Container(color: Colors.grey[100]));
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}