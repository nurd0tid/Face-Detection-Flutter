import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectionService {
  final FaceDetector _faceDetector;

  // Inisialisasi detektor wajah dengan pengaturan default
  FaceDetectionService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            performanceMode: FaceDetectorMode.accurate, // Mode deteksi akurat
            enableLandmarks: true, // Deteksi landmark wajah
            enableContours: true, // Deteksi kontur wajah
            enableClassification: true, // Deteksi klasifikasi seperti senyum
          ),
        );

  /// Mendeteksi wajah dari file gambar
  Future<List<Face>> detectFaces(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      return faces;
    } catch (e) {
      throw Exception('Gagal mendeteksi wajah: $e');
    }
  }

  /// Menutup detektor untuk membebaskan sumber daya
  void dispose() {
    _faceDetector.close();
  }
}
