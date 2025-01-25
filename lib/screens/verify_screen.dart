import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import '../services/face_detection_service.dart';
import '../services/ml_service.dart';
import '../services/supabase_service.dart';
import '../config/constants.dart'; // Import untuk DEFAULT_USER_ID dan FACE_SIMILARITY_THRESHOLD

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({Key? key}) : super(key: key);

  @override
  _VerifyScreenState createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  final MLService _mlService = MLService();
  final SupabaseService _supabaseService = SupabaseService();

  String _status = 'Ambil gambar untuk memverifikasi wajah.';
  File? _imageFile;
  CameraController? _cameraController;
  bool _isProcessing = false;
  bool _showRetryButton = false;

  @override
  void initState() {
    super.initState();
    _initializeModel();
    _initializeCamera();
  }

  /// Inisialisasi model TFLite
  Future<void> _initializeModel() async {
    try {
      await _mlService.initializeModel();
    } catch (e) {
      setState(() {
        _status = 'Gagal menginisialisasi model TFLite: $e';
      });
    }
  }

  /// Inisialisasi kamera
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
    );

    await _cameraController?.initialize();
    setState(() {});

    _pickImage();
  }

  /// Fungsi untuk mengambil gambar dari kamera
  Future<void> _pickImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
        _showRetryButton = false;
      });

      final XFile image = await _cameraController!.takePicture();
      _imageFile = File(image.path);

      await _processImage();
    } catch (e) {
      setState(() {
        _status = 'Gagal mengambil gambar: $e';
        _showRetryButton = true;
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// Fungsi untuk memproses gambar dan melakukan verifikasi
  Future<void> _processImage() async {
    try {
      if (_imageFile == null) return;

      // Deteksi wajah pada gambar
      final faces = await _faceDetectionService.detectFaces(_imageFile!);
      if (faces.isEmpty) {
        setState(() {
          _status = 'Tidak ada wajah yang terdeteksi. Coba lagi.';
          _showRetryButton = true;
        });
        return;
      }

      // Ekstraksi vektor wajah dari gambar
      final faceVector = await _mlService.extractFaceEmbedding(_imageFile!);

      // Ambil data pengguna dari database menggunakan DEFAULT_USER_ID
      final user = await _supabaseService.fetchUserById(DEFAULT_USER_ID);
      if (user == null) {
        setState(() {
          _status = 'Data pengguna tidak ditemukan di database.';
          _showRetryButton = true;
        });
        return;
      }

      // Parse vektor wajah yang disimpan di database
      final savedVectorString = user['face_vector'] as String;
      final savedVector =
          savedVectorString.substring(1, savedVectorString.length - 1).split(',').map((e) => double.parse(e)).toList();

      // Bandingkan vektor wajah
      final similarity = _mlService.calculateSimilarity(faceVector, savedVector);

      // Tentukan hasil verifikasi berdasarkan FACE_SIMILARITY_THRESHOLD
      if (similarity >= FACE_SIMILARITY_THRESHOLD) {
        setState(() {
          _status = 'Wajah terverifikasi dengan kemiripan $similarity.';
          _showRetryButton = false;
        });
      } else {
        setState(() {
          _status = 'Wajah tidak cocok. Kemiripan: $similarity.';
          _showRetryButton = true;
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Terjadi kesalahan: $e';
        _showRetryButton = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _mlService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Face'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_cameraController != null && _cameraController!.value.isInitialized)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _status.contains('terverifikasi')
                        ? Colors.green // Warna hijau jika wajah terverifikasi
                        : _status.contains('tidak cocok')
                            ? Colors.red // Warna merah jika wajah tidak cocok
                            : Colors.blue, // Default warna biru
                    width: 4.0,
                  ),
                ),
                child: ClipOval(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              )
            else
              const Text('Menginisialisasi kamera...'),
            const SizedBox(height: 20),
            if (_isProcessing) const CircularProgressIndicator() else Text(_status),
            const SizedBox(height: 20),
            if (_showRetryButton)
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Ulang'),
              ),
          ],
        ),
      ),
    );
  }

}
