// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../theme/app_theme.dart';

// class ProjectsPage extends StatefulWidget {
//   const ProjectsPage({super.key});

//   @override
//   State<ProjectsPage> createState() => _ProjectsPageState();
// }

// class _ProjectsPageState extends State<ProjectsPage> {
//   List<String> projects = [];

//   @override
//   void initState() {
//     super.initState();
//     loadProjects();
//   }

//   Future<void> loadProjects() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = prefs.getStringList('my_projects') ?? [];

//     // filter file yang hilang
//     final valid = data.where((path) => File(path).existsSync()).toList();

//     setState(() => projects = valid);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.softPink1,
//       body: SafeArea(
//         child: projects.isEmpty ? _emptyState() : _gridState(),
//       ),
//     );
//   }

//   // -------- EMPTY STATE ---------
//   Widget _emptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset(
//             "assets/illustrations/empty_folder.png",
//             height: 140,
//           ),
//           const SizedBox(height: 20),
//           Text(
//             "No Projects Yet",
//             style: GoogleFonts.poppins(
//               fontSize: 22,
//               fontWeight: FontWeight.w700,
//               color: AppTheme.accentPurple,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "Your saved photo strips will appear here!",
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // -------- GRID STATE ---------
//   Widget _gridState() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: GridView.builder(
//         itemCount: projects.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           mainAxisSpacing: 18,
//           crossAxisSpacing: 18,
//           childAspectRatio: 0.5,
//         ),
//         itemBuilder: (context, index) {
//           final file = projects[index];
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => ProjectDetailScreen(path: file, heroTag: index),
//                 ),
//               );
//             },
//             child: Hero(
//               tag: index,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(18),
//                 child: Container(
//                   color: Colors.white,
//                   child: Image.file(
//                     File(file),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


// // ------------------ DETAIL PAGE ------------------

// class ProjectDetailScreen extends StatelessWidget {
//   final String path;
//   final int heroTag;

//   const ProjectDetailScreen({
//     super.key,
//     required this.path,
//     required this.heroTag,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.softPink1,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // BACK BUTTON
//             Padding(
//               padding: const EdgeInsets.only(left: 16, top: 10),
//               child: Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: const Icon(
//                       Icons.arrow_back,
//                       size: 30,
//                       color: AppTheme.primaryPink,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 10),

//             // FULL IMAGE
//             Expanded(
//               child: Center(
//                 child: Hero(
//                   tag: heroTag,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(20),
//                     child: Image.file(
//                       File(path),
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
