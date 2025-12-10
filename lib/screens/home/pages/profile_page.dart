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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  String? avatarUrl;

  // Load data user dari Supabase
  Future<void> _loadUserData() async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user != null) {
    setState(() {
      userEmail = user.email ?? "No Email";
      userName = user.userMetadata?['username'] ?? "User";
    });

    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('username, avatar_url')
          .eq('id', user.id)
          .single();

      setState(() {
        userName = response['username'] ?? userName;
        avatarUrl = response['avatar_url'];
      });

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
          colors: [
            Color(0xFFFBD1DC),
            Color(0xFFF5B7C6),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              CircleAvatar(
  radius: 50,
  backgroundImage: avatarUrl != null
      ? NetworkImage(avatarUrl!)
      : const AssetImage("assets/logo/logo.png") as ImageProvider,
),
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

              Text(
                userEmail,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              // Menu Items
              _menu("Edit Profile", Icons.person, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileEditPage())
                );
              }),

              _menu("About App", Icons.info, onTap: () {
                _showAboutDialog(context);
              }),

              _menu("Logout", Icons.logout, onTap: () {
                _logout(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  // Menu Widget yang bisa dipakai untuk setiap item
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

  // Fungsi untuk aksi logout
  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Logout",
            style: TextStyle(color: AppTheme.primaryPink),
          ),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                try {
                  // Logout dari Supabase
                  await Supabase.instance.client.auth.signOut();

                  // Navigasi ke LoginScreen dan hapus semua route sebelumnya
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  // Tampilkan error jika logout gagal
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout failed: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Logout",
              ),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menampilkan dialog "About App"
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Pict A Boo",
            style: TextStyle(
              color: AppTheme.primaryPink,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Version: 1.0.0",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Made with Flutter 💖",
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
