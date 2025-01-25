class ValidationUtils {
  /// Validasi apakah nilai kemiripan wajah memenuhi ambang batas
  static bool isFaceMatch(double similarity, {double threshold = 0.6}) {
    return similarity >= threshold;
  }

  /// Validasi string kosong atau null
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validasi format ID pengguna (contoh: hanya menerima UUID)
  static bool isValidUserId(String userId) {
    final regex = RegExp(r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$');
    return regex.hasMatch(userId);
  }
}
