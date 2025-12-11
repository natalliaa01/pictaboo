import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Pastikan path import ini sesuai dengan struktur foldermu
import 'package:pictaboo/theme/app_theme.dart'; 

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final supabase = Supabase.instance.client;

  File? _selectedImage;
  String? avatarUrl;
  TextEditingController? usernameController;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from("users")
          .select("username, avatar_url")
          .eq("id", user.id)
          .single()
          .timeout(const Duration(seconds: 5));

      usernameController =
          TextEditingController(text: response["username"] ?? "");
      avatarUrl = response["avatar_url"];
    } catch (e) {
      // Fallback jika user belum punya row di tabel users
      usernameController =
          TextEditingController(text: user.userMetadata?["username"] ?? "");
      avatarUrl = null;
      print("Load profile error: $e");
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() {
        _selectedImage = File(file.path);
      });
    }
  }

  // REVISI 1: Menambahkan Timestamp agar nama file unik & anti-cache
  Future<String?> _uploadAvatar(String userId) async {
    if (_selectedImage == null) return avatarUrl;

    final fileExt = _selectedImage!.path.split('.').last;
    
    // Kita tambahkan waktu sekarang ke nama file
    final fileName = "avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt";
    final filePath = "$userId/$fileName";

    try {
      await supabase.storage.from("avatars").upload(
        filePath,
        _selectedImage!,
        fileOptions: const FileOptions(upsert: true),
      );

      return supabase.storage.from("avatars").getPublicUrl(filePath);
    } catch (e) {
      print("Error uploading avatar: $e");
      return null;
    }
  }

  // File: lib/screens/home/pages/profile_edit.dart

Future<void> _saveProfile() async {
  final user = supabase.auth.currentUser;
  if (user == null) return;

  setState(() => isLoading = true);

  try {
    final newAvatarUrl = await _uploadAvatar(user.id);
    final urlToSave = newAvatarUrl ?? avatarUrl;

    // --- PERBAIKAN DI SINI ---
    // Ganti .update() menjadi .upsert()
    // Kita WAJIB menyertakan 'id' agar Supabase tahu baris mana yang dimaksud
    await supabase.from("users").upsert({
      "id": user.id, 
      "username": usernameController!.text,
      "avatar_url": urlToSave,
    });
    // -------------------------

    await supabase.auth.updateUser(
      UserAttributes(data: {"username": usernameController!.text}),
    );

    if (mounted) {
      // Tetap kirim url balik supaya transisi mulus
      Navigator.pop(context, urlToSave);
    }
  } catch (e) {
    print("Error saving profile: $e");
    setState(() => isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan profil: $e")),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading full screen jika data belum siap
    if (isLoading && usernameController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFBD1DC),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.pink.shade400,
        title: const Text(
          "Edit Profile",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      // Gunakan Stack agar Loading Indicator bisa muncul di atas konten saat _saveProfile
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar Section
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Colors.pink.shade200,
                          Colors.pink.shade400,
                        ],
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : (avatarUrl != null
                              ? NetworkImage(avatarUrl!)
                              : const AssetImage("assets/logo/logo.png")
                                  as ImageProvider),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Text(
                  "Tap to change photo",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 30),

                // Form Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Username",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                      shadowColor: Colors.pink.shade200,
                    ),
                    child: Text(
                      isLoading ? "Saving..." : "Save Changes",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Overlay Loading Indicator jika sedang saving
          if (isLoading && usernameController != null)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}