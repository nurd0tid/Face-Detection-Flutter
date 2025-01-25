import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';

class SupabaseService {
  final SupabaseClient client;

  // Inisialisasi klien Supabase dengan URL dan Anon Key
  SupabaseService() : client = SupabaseClient(SUPABASE_URL, SUPABASE_KEY);

  /// Menyimpan data pengguna ke tabel "users_faces"
  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      await client.from('users_faces').insert(userData);
    } catch (e) {
      throw Exception('Gagal menyimpan data: $e');
    }
  }

  /// Mengambil data pengguna berdasarkan userId
  Future<Map<String, dynamic>> fetchUserById(String userId) async {
    try {
      final List<dynamic> result = await client.from('users_faces').select('*').eq('user_id', userId).limit(1);

      if (result.isEmpty) {
        throw Exception('Data pengguna tidak ditemukan.');
      }

      return result.first as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Gagal mengambil data pengguna: $e');
    }
  }

  /// Mengambil semua data pengguna
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      final List<dynamic> result = await client.from('users_faces').select('*');

      return result.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Gagal mengambil semua data pengguna: $e');
    }
  }

  /// Menghapus data pengguna berdasarkan userId
  Future<void> deleteUserById(String userId) async {
    try {
      await client.from('users_faces').delete().eq('user_id', userId);
    } catch (e) {
      throw Exception('Gagal menghapus data pengguna: $e');
    }
  }
}
