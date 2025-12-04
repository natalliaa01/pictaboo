import 'package:flutter/material.dart';
import 'package:pictaboo/theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/logo/logo.png"),
              ),
              const SizedBox(height: 20),

              const Text(
                "User Name",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              const SizedBox(height: 6),

              const Text(
                "user@gmail.com",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 30),

              // Menu Items
              _menu("Edit Profile", Icons.person, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              }),

              _menu("Change Password", Icons.lock, onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                );
              }),

               _menu("About App", Icons.info, onTap: () {
                _showAboutDialog(context); // Menggunakan AlertDialog untuk "About App"
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
          title: Text("Logout", 
          style: TextStyle(
            color: AppTheme.primaryPink
          ),),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Menutup dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Aksi logout (misalnya dengan Firebase Auth atau lainnya)
                Navigator.pop(context); // Menutup dialog
                // Lakukan logout di sini
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}

// Dummy page untuk Edit Profile
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Profile"),
      ),
      body: Center(child: Text("Edit Profile Page")),
    );
  }
}

// Dummy page untuk Change Password
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
      ),
      body: Center(child: Text("Change Password Page")),
    );
  }
}

// Fungsi untuk menampilkan dialog "About App"
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Pict A Boo",
            style: TextStyle(
              color: AppTheme.primaryPink,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Version: 1.0.0",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
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
