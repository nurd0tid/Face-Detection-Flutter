
// using model Pillar
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  late Interpreter _interpreter;

  /// Inisialisasi model TFLite
  Future<void> initializeModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/facenet.tflite');
      print('Model berhasil diinisialisasi');
      checkModelDetails();
    } catch (e) {
      print('Error: $e');
      throw Exception('Gagal menginisialisasi model TFLite: $e');
    }
  }

  /// Mengecek detail input dan output model
  void checkModelDetails() {
    final inputShape = _interpreter.getInputTensor(0).shape;
    final outputShape = _interpreter.getOutputTensor(0).shape;

    print("Input Shape: $inputShape");
    print("Output Shape: $outputShape");
  }

  /// Mengekstraksi vektor wajah dari gambar
  Future<List<double>> extractFaceEmbedding(File imageFile) async {
    try {
      // Baca gambar dari file
      final rawImage = await imageFile.readAsBytes();

      // Decode dan preprocess gambar
      final decodedImage = img.decodeImage(rawImage);
      if (decodedImage == null) {
        throw Exception('Gagal membaca gambar.');
      }

      // Resize gambar ke ukuran yang sesuai dengan model (160x160)
      final resizedImage = img.copyResize(decodedImage, width: 160, height: 160);

      // Konversi gambar menjadi array piksel dalam format input model
      final input = _preprocessImage(resizedImage);

      // Menyiapkan array output untuk menyimpan vektor hasil model
      final output = List.generate(1, (i) => List.filled(512, 0.0)); // Sesuai dengan output shape [1, 512]

      // Jalankan model TFLite
      _interpreter.run(input, output);

      // Kembalikan vektor hasil sebagai List<double>
      return List<double>.from(output[0]);
    } catch (e) {
      throw Exception('Gagal mengekstraksi vektor wajah: $e');
    }
  }

  /// Menghitung kemiripan antara dua vektor wajah menggunakan Cosine Similarity
  double calculateSimilarity(List<double> vector1, List<double> vector2) {
    if (vector1.length != vector2.length) {
      throw Exception('Vektor tidak memiliki panjang yang sama.');
    }

    double dotProduct = 0.0;
    double magnitude1 = 0.0;
    double magnitude2 = 0.0;

    for (int i = 0; i < vector1.length; i++) {
      dotProduct += vector1[i] * vector2[i];
      magnitude1 += vector1[i] * vector1[i];
      magnitude2 += vector2[i] * vector2[i];
    }

    magnitude1 = sqrt(magnitude1);
    magnitude2 = sqrt(magnitude2);

    if (magnitude1 == 0 || magnitude2 == 0) {
      throw Exception('Salah satu vektor memiliki magnitude nol.');
    }

    return dotProduct / (magnitude1 * magnitude2);
  }

  /// Menutup interpreter untuk membebaskan sumber daya
  void dispose() {
    _interpreter.close();
  }

  /// Fungsi untuk memproses gambar sebelum dimasukkan ke model
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    final input = List.generate(
      1, // Batch size
      (b) => List.generate(
        160, // Tinggi gambar sesuai model
        (y) => List.generate(
          160, // Lebar gambar sesuai model
          (x) {
            // Mendapatkan nilai piksel pada koordinat (x, y)
            final pixel = image.getPixel(x, y);

            // Ekstrak channel warna dari format ARGB
            final r = img.getRed(pixel) / 127.5 - 1.0; // Normalisasi ke [-1.0, 1.0]
            final g = img.getGreen(pixel) / 127.5 - 1.0; // Normalisasi ke [-1.0, 1.0]
            final b = img.getBlue(pixel) / 127.5 - 1.0; // Normalisasi ke [-1.0, 1.0]

            // Kembalikan nilai RGB dalam format normalisasi
            return [r, g, b];
          },
        ),
      ),
    );
    return input;
  }
}
