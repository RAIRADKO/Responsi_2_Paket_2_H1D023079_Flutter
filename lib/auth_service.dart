import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class AuthService {
  static Future<void> register(String name, String email, String password) async {
    http.Response response;
    
    try {
      response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Koneksi timeout. Pastikan server API berjalan dan dapat diakses.');
        },
      );
    } on http.ClientException catch (e) {
      throw Exception('Gagal terhubung ke server: ${e.message}. Pastikan server API berjalan di $baseUrl');
    } on FormatException catch (e) {
      throw Exception('Format URL tidak valid: ${e.message}');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Registrasi gagal';
      try {
        if (response.body.isNotEmpty) {
          final errorData = json.decode(response.body);
          if (errorData is Map) {
            errorMessage = errorData['message'] ?? 
                          errorData['error'] ?? 
                          errorData.toString();
          } else {
            errorMessage = response.body;
          }
        } else {
          errorMessage = 'Terjadi kesalahan saat registrasi (Status: ${response.statusCode})';
        }
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : 'Terjadi kesalahan saat registrasi';
      }
      throw Exception(errorMessage);
    }
  }

  static Future<void> login(String email, String password) async {
    http.Response response;
    
    try {
      response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Koneksi timeout. Pastikan server API berjalan dan dapat diakses.');
        },
      );
    } on http.ClientException catch (e) {
      throw Exception('Gagal terhubung ke server: ${e.message}. Pastikan server API berjalan di $baseUrl');
    } on FormatException catch (e) {
      throw Exception('Format URL tidak valid: ${e.message}');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }

    // Handle berbagai status code success
    if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Login gagal';
      try {
        if (response.body.isNotEmpty) {
          final errorData = json.decode(response.body);
          if (errorData is Map) {
            errorMessage = errorData['message'] ?? 
                          errorData['error'] ?? 
                          (errorData['errors'] != null ? errorData['errors'].toString() : null) ??
                          'Email atau password salah';
          } else {
            errorMessage = response.body;
          }
        } else {
          errorMessage = 'Email atau password salah (Status: ${response.statusCode})';
        }
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : 'Email atau password salah';
      }
      throw Exception(errorMessage);
    }

    // Parse response body
    Map<String, dynamic> data;
    try {
      if (response.body.isEmpty) {
        throw Exception('Response body kosong');
      }
      data = json.decode(response.body);
    } catch (e) {
      throw Exception('Format response tidak valid: ${response.body}');
    }

    // Cari token dalam berbagai format response
    String? token;
    
    // Format 1: access_token langsung
    if (data.containsKey('access_token')) {
      token = data['access_token']?.toString();
    }
    // Format 2: token langsung
    else if (data.containsKey('token')) {
      token = data['token']?.toString();
    }
    // Format 3: data.access_token
    else if (data.containsKey('data') && data['data'] is Map) {
      final dataMap = data['data'] as Map<String, dynamic>;
      token = dataMap['access_token']?.toString() ?? dataMap['token']?.toString();
    }
    // Format 4: user.token atau user.access_token
    else if (data.containsKey('user') && data['user'] is Map) {
      final userMap = data['user'] as Map<String, dynamic>;
      token = userMap['access_token']?.toString() ?? userMap['token']?.toString();
    }

    if (token == null || token.isEmpty) {
      throw Exception('Token tidak ditemukan dalam response. Response: ${response.body}');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    } catch (e) {
      throw Exception('Gagal menyimpan token: ${e.toString()}');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}