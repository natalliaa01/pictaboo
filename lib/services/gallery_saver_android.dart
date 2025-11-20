import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GallerySaverAndroid {
  static const platform = MethodChannel('pictaboo/gallery');

  static Future<bool> saveImageToGallery(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final result = await platform.invokeMethod(
        'saveImage',
        {
          'bytes': Uint8List.fromList(bytes),
          'name': "pictaboo_${DateTime.now().millisecondsSinceEpoch}.jpg",
        },
      );
      return result == true;
    } catch (e) {
      print("SAVE ERROR: $e");
      return false;
    }
  }

  static Future<void> saveToMyProjects(String path) async {
    final prefs = await SharedPreferences.getInstance();   // ← dijamin tidak merah lagi
    final old = prefs.getStringList('my_projects') ?? [];
    old.add(path);
    await prefs.setStringList('my_projects', old);
  }
}
