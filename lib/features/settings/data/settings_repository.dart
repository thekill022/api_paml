import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';

class SettingsRepository {
  static const _tokenKey = 'driveease_access_token';

  Future<void> updateName({
    required int userId,
    required String firstName,
    required String lastName,
  }) async {
    final response = await http.patch(
      ApiConstants.uri('/user/$userId'),
      headers: await _jsonAuthHeaders(),
      body: jsonEncode({'firstName': firstName, 'lastName': lastName}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SettingsException(
        _message(_decode(response.body), 'Gagal mengubah nama'),
      );
    }
  }

  Future<void> updatePassword({
    required int userId,
    required String password,
  }) async {
    final response = await http.patch(
      ApiConstants.uri('/user/$userId'),
      headers: await _jsonAuthHeaders(),
      body: jsonEncode({'password': password}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SettingsException(
        _message(_decode(response.body), 'Gagal mengubah password'),
      );
    }
  }

  Future<Map<String, String>> _jsonAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      throw const SettingsException(
        'Token tidak ditemukan. Silakan login ulang.',
      );
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
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

class SettingsException implements Exception {
  const SettingsException(this.message);

  final String message;

  @override
  String toString() => message;
}
