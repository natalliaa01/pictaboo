import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.softPink1,
      body: SafeArea(
        child: Column(
          children: [

            const SizedBox(height: 20),

            // TITLE
            Text(
              "Profile",
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryPink,
              ),
            ),

            const SizedBox(height: 30),

            // AVATAR
            Center(
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/illustrations/user_avatar.png"),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // USERNAME
            Text(
              "Guest User",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryPink,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "photobooth lover ✨",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 30),

            // MENU LIST
            _menuButton(
              icon: Icons.person,
              label: "Edit Profile",
              onTap: () {},
            ),

            _menuButton(
              icon: Icons.info_outline,
              label: "About App",
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "Pict A Boo",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "Made with Flutter 💖",
                );
              },
            ),

            _menuButton(
              icon: Icons.settings,
              label: "App Settings",
              onTap: () {},
            ),

            const Spacer(),

            // LOGOUT BUTTON (opsional)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryPink,
                    side: const BorderSide(color: AppTheme.primaryPink),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Logout",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryPink,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _menuButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryPink, size: 28),
              const SizedBox(width: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentPurple,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppTheme.primaryPink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
