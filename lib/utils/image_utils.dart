import 'dart:io';
import 'package:image/image.dart' as img;

class ImageUtils {
  /// Fungsi untuk resize gambar ke ukuran tertentu
  static img.Image resizeImage(File imageFile, {int width = 112, int height = 112}) {
    // Decode gambar dari file
    final rawImage = imageFile.readAsBytesSync();
    final decodedImage = img.decodeImage(rawImage);

    if (decodedImage == null) {
      throw Exception('Gagal membaca gambar.');
    }

    // Resize gambar
    return img.copyResize(decodedImage, width: width, height: height);
  }

  /// Konversi gambar menjadi format numerik yang sesuai untuk input model
  static List<List<List<double>>> preprocessImage(img.Image image) {
    return List.generate(
      image.height,
      (y) => List.generate(
        image.width,
        (x) {
          final pixel = image.getPixel(x, y);

          // Mendapatkan nilai R, G, B
          final r = img.getRed(pixel) / 255.0; // Channel merah
          final g = img.getGreen(pixel) / 255.0; // Channel hijau
          final b = img.getBlue(pixel) / 255.0; // Channel biru

          return [r, g, b];
        },
      ),
    );
  }
}
