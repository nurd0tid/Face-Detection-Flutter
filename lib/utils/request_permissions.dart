import 'package:permission_handler/permission_handler.dart';

class RequestPermissions {
  /// Meminta izin kamera
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Meminta izin penyimpanan
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Meminta semua izin yang diperlukan
  static Future<bool> requestAllPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    // Periksa apakah semua izin diberikan
    return statuses.values.every((status) => status.isGranted);
  }
}
