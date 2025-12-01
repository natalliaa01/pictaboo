// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart' as path;

// import '../../services/image_merge_service.dart';
// import '../../services/gallery_saver_android.dart';

// class FinalPreviewScreen extends StatefulWidget {
//   final String framePath;
//   final List<String> capturedPhotos;

//   const FinalPreviewScreen({
//     super.key,
//     required this.framePath,
//     required this.capturedPhotos,
//   });

//   @override
//   State<FinalPreviewScreen> createState() => _FinalPreviewScreenState();
// }

// class _FinalPreviewScreenState extends State<FinalPreviewScreen> {
//   File? mergedResult;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _mergeAll();
//   }

//   Future<void> _mergeAll() async {
//     // Merge 3 photos into frame
//     final result = await ImageMergeService.mergePhotoWithFrame(
//       widget.capturedPhotos[0],
//       widget.framePath,
//     );

//     // (optional) If different frame layout, use all 3 photos accordingly
//     // For now apply single merge — we will adjust layout if needed.

//     setState(() {
//       mergedResult = result;
//       isLoading = false;
//     });
//   }

//   Future<void> _saveToProjects() async {
//     if (mergedResult == null) return;

//     final ok = await GallerySaverAndroid.saveImageToGallery(mergedResult!);

//     if (ok) {
//       await GallerySaverAndroid.saveToMyProjects(mergedResult!.path);
//     }

//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(ok ? "Saved to My Projects!" : "Failed to save."),
//       ),
//     );

//     if (ok) {
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFBD1DC),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: Colors.pink,
//       ),
//       body: SafeArea(
//         child: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // BIG MERGED FRAME PREVIEW
//                   Expanded(
//                     child: Center(
//                       child: AspectRatio(
//                         aspectRatio: 1 / 2.8,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(18),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.15),
//                                 blurRadius: 16,
//                                 offset: const Offset(0, 8),
//                               ),
//                             ],
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(18),
//                             child: Image.file(
//                               mergedResult!,
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 16),

//                   // SAVE BUTTON
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 24),
//                     child: SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _saveToProjects,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFB02A67),
//                           padding: const EdgeInsets.symmetric(
//                               vertical: 16, horizontal: 12),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           elevation: 2,
//                         ),
//                         child: const Text(
//                           "Save",
//                           style: TextStyle(
//                             fontSize: 20,
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 20)
//                 ],
//               ),
//       ),
//     );
//   }
// }
