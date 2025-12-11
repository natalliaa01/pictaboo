import 'package:flutter/material.dart';
import 'package:pictaboo/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/login_screen.dart';
import 'profile_edit.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      if (mounted) {
        setState(() {
          userEmail = user.email ?? "No Email";
          userName = user.userMetadata?['username'] ?? "User";
        });
      }

      try {
        final response = await Supabase.instance.client
            .from('users')
            .select('username, avatar_url')
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            userName = response['username'] ?? userName;
            // Tambahkan timestamp agar gambar selalu fresh
            if (response['avatar_url'] != null) {
              avatarUrl = "${response['avatar_url']}?v=${DateTime.now().millisecondsSinceEpoch}";
            }
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFBD1DC), Color(0xFFF5B7C6)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- BAGIAN AVATAR YANG DIPERBAIKI ---
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
                  ],
                ),
                child: ClipOval(
                  child: avatarUrl != null
                      ? Image.network(
                          avatarUrl!,
                          fit: BoxFit.cover,
                          // Tampilkan loading saat gambar sedang diambil
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          // Tampilkan logo jika gambar error (misal 404)
                          errorBuilder: (context, error, stackTrace) {
                            print("Error loading image: $error"); // Cek console debug
                            return Image.asset("assets/logo/logo.png", fit: BoxFit.cover);
                          },
                        )
                      : Image.asset("assets/logo/logo.png", fit: BoxFit.cover),
                ),
              ),
              // -------------------------------------

              const SizedBox(height: 20),

              Text(
                userName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 6),
              Text(userEmail, style: const TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 30),

              // Menu Items
              _menu("Edit Profile", Icons.person, onTap: () async {
                // TANGKAP DATA BALIK DARI HALAMAN EDIT
                final resultUrl = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileEditPage())
                );

                // Jika ada URL yang dikembalikan, langsung pasang!
                if (resultUrl != null && resultUrl is String) {
                  print("Menerima URL baru: $resultUrl");
                  setState(() {
                    // Tambah timestamp lagi untuk memastikan refresh
                    avatarUrl = "$resultUrl?t=${DateTime.now().millisecondsSinceEpoch}";
                  });
                  // Load data lengkap di background untuk sinkronisasi
                  _loadUserData(); 
                } else if (resultUrl == true) {
                  // Fallback jika cuma return true
                  _loadUserData();
                }
              }),

              _menu("About App", Icons.info, onTap: () => _showAboutDialog(context)),
              _menu("Logout", Icons.logout, onTap: () => _logout(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menu(String title, IconData icon, {required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.pink),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _logout(BuildContext context) {
    // ... (kode logout sama seperti sebelumnya)
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Logout", style: TextStyle(color: AppTheme.primaryPink)),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  // Handle error
                }
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    // ... (kode about dialog sama seperti sebelumnya)
     showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Pict A Boo", style: TextStyle(color: AppTheme.primaryPink, fontWeight: FontWeight.bold)),
          content: const Text("Made with Flutter 💖"),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
        );
      },
    );
  }
}