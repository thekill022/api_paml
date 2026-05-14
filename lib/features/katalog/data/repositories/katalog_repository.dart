import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/katalog_model.dart';

class KatalogRepository {
  static const _tokenKey = 'driveease_access_token';

  Future<List<KatalogModel>> fetchKatalog() async {
    return _fetchList('/katalog', 'Gagal mengambil katalog');
  }

  Future<List<KatalogModel>> searchKatalog(String keyword) async {
    if (keyword.trim().isEmpty) return fetchKatalog();
    return _fetchList(
      '/katalog/search/${Uri.encodeComponent(keyword.trim())}',
      'Gagal mencari katalog',
    );
  }

  Future<List<KatalogModel>> fetchByStatus(bool status) async {
    return _fetchList('/katalog/status/$status', 'Gagal memfilter katalog');
  }

  Future<List<KatalogModel>> _fetchList(String path, String fallback) async {
    final response = await http.get(
      ApiConstants.uri(path),
      headers: await _authHeaders(),
    );

    final body = _decode(response.body);
    if (response.statusCode != 200) {
      throw KatalogException(_message(body, fallback));
    }
    if (body is! List) return [];
    return body
        .whereType<Map<String, dynamic>>()
        .map(KatalogModel.fromJson)
        .toList();
  }

  Future<void> createKatalog({
    required String nama,
    required String harga,
    required bool status,
    required int kategoriId,
    required String imagePath,
  }) async {
    final request =
        http.MultipartRequest('POST', ApiConstants.uri('/katalog'))
          ..headers.addAll(await _authHeaders())
          ..fields.addAll({
            'nama': nama,
            'harga': harga,
            'status': status.toString(),
            'kategoriId': kategoriId.toString(),
          })
          ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    await _sendMultipart(request, 'Gagal menambah katalog');
  }

  Future<void> updateKatalog({
    required int id,
    required String nama,
    required String harga,
    required bool status,
    required int kategoriId,
    String? imagePath,
  }) async {
    final request =
        http.MultipartRequest('PATCH', ApiConstants.uri('/katalog/$id'))
          ..headers.addAll(await _authHeaders())
          ..fields.addAll({
            'nama': nama,
            'harga': harga,
            'status': status.toString(),
            'kategoriId': kategoriId.toString(),
          });

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    }

    await _sendMultipart(request, 'Gagal mengubah katalog');
  }

  Future<void> deleteKatalog(int id) async {
    final response = await http.delete(
      ApiConstants.uri('/katalog/$id'),
      headers: await _authHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw KatalogException(
        _message(_decode(response.body), 'Gagal menghapus katalog'),
      );
    }
  }

  String imageUrl(String path) => '${ApiConstants.baseUrl}/public/$path';

  Future<void> _sendMultipart(
    http.MultipartRequest request,
    String fallback,
  ) async {
    final response = await request.send();
    final rawBody = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw KatalogException(_message(_decode(rawBody), fallback));
    }
  }

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      throw const KatalogException(
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

class KatalogException implements Exception {
  const KatalogException(this.message);

  final String message;

  @override
  String toString() => message;
}
