import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/kategori_model.dart';

class KategoriRepository {
  static const _tokenKey = 'driveease_access_token';

  Future<List<KategoriModel>> fetchKategori() async {
    final response = await http.get(
      ApiConstants.uri('/kategori'),
      headers: await _authHeaders(),
    );

    final body = _decode(response.body);
    if (response.statusCode != 200) {
      throw KategoriException(_message(body, 'Gagal mengambil kategori'));
    }
    if (body is! List) return [];
    return body
        .whereType<Map<String, dynamic>>()
        .map(KategoriModel.fromJson)
        .toList();
  }

  Future<void> createKategori(String kategori) async {
    final response = await http.post(
      ApiConstants.uri('/kategori'),
      headers: await _jsonAuthHeaders(),
      body: jsonEncode({'kategori': kategori}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw KategoriException(
        _message(_decode(response.body), 'Gagal menambah kategori'),
      );
    }
  }

  Future<void> updateKategori({
    required int id,
    required String kategori,
  }) async {
    final response = await http.patch(
      ApiConstants.uri('/kategori/$id'),
      headers: await _jsonAuthHeaders(),
      body: jsonEncode({'kategori': kategori}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw KategoriException(
        _message(_decode(response.body), 'Gagal mengubah kategori'),
      );
    }
  }

  Future<void> deleteKategori(int id) async {
    final response = await http.delete(
      ApiConstants.uri('/kategori/$id'),
      headers: await _authHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw KategoriException(
        _message(_decode(response.body), 'Gagal menghapus kategori'),
      );
    }
  }

  Future<Map<String, String>> _jsonAuthHeaders() async {
    return {...await _authHeaders(), 'Content-Type': 'application/json'};
  }

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      throw const KategoriException(
        'Token tidak ditemukan. Silakan login ulang.',
      );
    }
    return {'Authorization': 'Bearer $token'};
  }

  Object? _decode(String rawBody) =>
      rawBody.isEmpty ? null : jsonDecode(rawBody);

  String _message(Object? body, String fallback) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String && message.isNotEmpty) return message;
      if (message is List && message.isNotEmpty) return message.join('\n');
    }
    return fallback;
  }
}

class KategoriException implements Exception {
  const KategoriException(this.message);

  final String message;

  @override
  String toString() => message;
}
