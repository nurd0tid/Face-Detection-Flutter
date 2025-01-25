class UserModel {
  final String userId; // ID unik pengguna
  final String name; // Nama pengguna
  final String faceVector; // Vektor wajah pengguna dalam bentuk string

  UserModel({
    required this.userId,
    required this.name,
    required this.faceVector,
  });

  // Factory untuk membuat UserModel dari JSON (response dari Supabase)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'],
      name: json['name'],
      faceVector: json['face_vector'],
    );
  }

  // Fungsi untuk mengonversi UserModel menjadi JSON (untuk disimpan di Supabase)
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'face_vector': faceVector,
    };
  }
}
