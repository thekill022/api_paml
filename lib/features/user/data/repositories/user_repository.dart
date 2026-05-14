import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

class UserRepository {
  static const _tokenKey = 'driveease_access_token';

  Future<List<UserModel>> fetchUsers() async {
    final response = await http.get(
      ApiConstants.uri('/user'),
      headers: await _authHeaders(),
    );

    final body = _decode(response.body);
    if (response.statusCode != 200) {
      throw UserException(_message(body, 'Gagal mengambil data user'));
    }

    if (body is! List) return [];
    return body
        .whereType<Map<String, dynamic>>()
        .map(UserModel.fromJson)
        .where((user) => user.id != 0)
        .toList();
  }

  Future<void> createUser({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      ApiConstants.uri('/user'),
      headers: await _jsonAuthHeaders(),
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UserException(
        _message(_decode(response.body), 'Gagal menambah user'),
      );
    }
  }

  Future<void> updateUser({
    required int id,
    required String firstName,
    required String lastName,
    required String email,
    required String role,
  }) async {
    final response = await http.patch(
      ApiConstants.uri('/user/$id'),
      headers: await _jsonAuthHeaders(),
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'role': role,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UserException(
        _message(_decode(response.body), 'Gagal mengubah user'),
      );
    }
  }

  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      ApiConstants.uri('/user/$id'),
      headers: await _authHeaders(),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UserException(
        _message(_decode(response.body), 'Gagal menghapus user'),
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
      throw const UserException('Token tidak ditemukan. Silakan login ulang.');
    }

    return {'Authorization': 'Bearer $token'};
  }

  Object? _decode(String rawBody) {
    if (rawBody.isEmpty) return null;
    return jsonDecode(rawBody);
  }

  String _message(Object? body, String fallback) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String && message.isNotEmpty) return message;
      if (message is List && message.isNotEmpty) return message.join('\n');
    }
    return fallback;
  }
}

class UserException implements Exception {
  const UserException(this.message);

  final String message;

  @override
  String toString() => message;
}
