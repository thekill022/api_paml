import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';

class AuthRepository {
  static const _tokenKey = 'driveease_access_token';

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> login({required String email, required String password}) async {
    final response = await http.post(
      ApiConstants.uri('/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = _decodeBody(response.body);
    if (response.statusCode != 202) {
      throw AuthException(_messageFromBody(body, 'Login gagal'));
    }

    final token = body['access_token'] as String?;
    if (token == null || token.isEmpty) {
      throw const AuthException('Token login tidak ditemukan');
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> registerMember({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      ApiConstants.uri('/user/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': 'member',
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = _decodeBody(response.body);
      throw AuthException(
        _messageFromBody(
          body,
          'Register gagal. Endpoint register member perlu dibuat public di backend.',
        ),
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Map<String, dynamic> _decodeBody(String rawBody) {
    if (rawBody.isEmpty) return {};
    final decoded = jsonDecode(rawBody);
    if (decoded is Map<String, dynamic>) return decoded;
    return {};
  }

  String _messageFromBody(Map<String, dynamic> body, String fallback) {
    final message = body['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is List && message.isNotEmpty) return message.join('\n');
    return fallback;
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
