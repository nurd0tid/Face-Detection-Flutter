import 'package:camera/camera.dart';

class CameraService {
  late CameraController _cameraController;
  CameraDescription? _selectedCamera;

  /// Getter untuk akses CameraController
  CameraController get cameraController => _cameraController;

  /// Inisialisasi kamera
  Future<void> initializeCamera() async {
    try {
      // Mendapatkan daftar kamera yang tersedia
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        throw Exception('Tidak ada kamera yang tersedia di perangkat.');
      }

      // Memilih kamera belakang sebagai default
      _selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      // Inisialisasi CameraController
      _cameraController = CameraController(
        _selectedCamera!,
        ResolutionPreset.high, // Resolusi tinggi
        enableAudio: false, // Nonaktifkan audio
      );

      // Memulai kamera
      await _cameraController.initialize();
    } catch (e) {
      throw Exception('Gagal menginisialisasi kamera: $e');
    }
  }

  /// Mengambil gambar dan mengembalikan path file gambar
  Future<String> captureImage() async {
    try {
      if (!_cameraController.value.isInitialized) {
        throw Exception('Kamera belum diinisialisasi.');
      }

      // Mengambil gambar
      final image = await _cameraController.takePicture();
      return image.path; // Path file gambar
    } catch (e) {
      throw Exception('Gagal mengambil gambar: $e');
    }
  }

  /// Menutup kamera untuk menghemat sumber daya
  void dispose() {
    if (_cameraController.value.isInitialized) {
      _cameraController.dispose();
    }
  }
}
