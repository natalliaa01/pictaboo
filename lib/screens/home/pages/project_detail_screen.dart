import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:pictaboo/theme/app_theme.dart'; // Import AppTheme

class ProjectDetailScreen extends StatelessWidget {
  final String imageUrl;

  const ProjectDetailScreen({super.key, required this.imageUrl});

  Future<String?> _downloadFile() async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      final bytes = response.bodyBytes;
      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/pictaboo_image.jpg';
      File(path).writeAsBytesSync(bytes);
      return path;
    } catch (e) {
      debugPrint("Download error: $e");
      return null;
    }
  }

  void _shareImage(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryPink)),
    );
    final path = await _downloadFile();
    if (context.mounted) Navigator.pop(context);

    if (path != null) {
      await Share.shareXFiles([XFile(path)], text: 'Lihat hasil fotoku dari Pict A Boo! ✨');
    }
  }

  void _saveImage(BuildContext context) async {
    if (!await Gal.hasAccess()) await Gal.requestAccess();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryPink)),
    );

    final path = await _downloadFile();
    if (context.mounted) Navigator.pop(context);

    if (path != null) {
      try {
        await Gal.putImage(path, album: 'Pictaboo');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Foto tersimpan di Galeri!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softPink1, // Background seragam
      appBar: AppBar(
        title: Text(
          "Detail Project",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryPink, // Teks Pink Tua
          ),
        ),
        backgroundColor: Colors.transparent, // Transparan agar elegan
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryPink),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentPurple.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 300,
                    child: Center(child: CircularProgressIndicator(color: AppTheme.primaryPink)),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      
      // TOMBOL AKSI DI BAWAH
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)), // Round top corners
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              )
            ]
          ),
          child: Row(
            children: [
              // Tombol Save (Outline Style)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _saveImage(context),
                  icon: const Icon(Icons.download_rounded),
                  label: const Text("Save"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryPink, // Icon & Text Pink
                    elevation: 0,
                    side: const BorderSide(color: AppTheme.primaryPink, width: 2), // Border Pink
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Tombol Share (Filled Style)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareImage(context),
                  icon: const Icon(Icons.share_rounded),
                  label: const Text("Share"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPink, // Full Pink
                    foregroundColor: Colors.white, // Text Putih
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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