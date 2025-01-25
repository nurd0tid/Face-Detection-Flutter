import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/face_detection_service.dart';
import '../services/ml_service.dart';
import '../services/supabase_service.dart';
import '../config/constants.dart'; // Tambahkan import untuk DEFAULT_USER_ID

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FaceDetectionService _faceDetectionService = FaceDetectionService();
  final MLService _mlService = MLService();
  final SupabaseService _supabaseService = SupabaseService();

  String _status = 'Ambil gambar untuk mendaftarkan wajah.';
  File? _imageFile;
  CameraController? _cameraController;
  bool _isProcessing = false;

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
  }

  /// Meminta izin kamera
  Future<bool> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      return true;
    } else {
      setState(() {
        _status = 'Izin kamera diperlukan untuk melanjutkan.';
      });
      return false;
    }
  }

  /// Fungsi untuk mengambil gambar dari kamera
  Future<void> _pickImage() async {
    // Periksa dan minta izin kamera
    final hasPermission = await _requestCameraPermission();
    if (!hasPermission) return;

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile image = await _cameraController!.takePicture();
      _imageFile = File(image.path);

      await _processImage();
    } catch (e) {
      setState(() {
        _status = 'Gagal mengambil gambar: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// Fungsi untuk memproses gambar dan menyimpan vektor wajah ke database
  Future<void> _processImage() async {
    try {
      if (_imageFile == null) return;

      // Deteksi wajah pada gambar
      final faces = await _faceDetectionService.detectFaces(_imageFile!);
      if (faces.isEmpty) {
        setState(() {
          _status = 'Tidak ada wajah yang terdeteksi. Coba lagi.';
        });
        return;
      }

      // Ekstraksi vektor wajah dari gambar
      final faceVector = await _mlService.extractFaceEmbedding(_imageFile!);

      // Simpan data pengguna ke database
      await _supabaseService.saveUser({
        'user_id': DEFAULT_USER_ID, // Gunakan DEFAULT_USER_ID
        'name': 'John Doe', // Nama pengguna (bisa diganti jika perlu)
        'face_vector': faceVector.toString(), // Simpan vektor sebagai string
      });

      setState(() {
        _status = 'Wajah berhasil didaftarkan.';
      });
    } catch (e) {
      setState(() {
        _status = 'Terjadi kesalahan: $e';
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
        title: const Text('Register Face'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_cameraController != null && _cameraController!.value.isInitialized)
              ClipOval(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CameraPreview(_cameraController!),
                ),
              )
            else
              const Text('Menginisialisasi kamera...'),
            const SizedBox(height: 20),
            if (_isProcessing) const CircularProgressIndicator() else Text(_status),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Ambil Gambar'),
            ),
          ],
        ),
      ),
    );
  }
}
