import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/api_constants.dart';
import 'auth_session.dart';

class AuthRepository {
  static const _tokenKey = 'driveease_access_token';

  Future<AuthSession?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return null;
    return _sessionFromToken(token);
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
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

    return _sessionFromToken(token);
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

  AuthSession _sessionFromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const AuthException('Format token tidak valid');
    }

    final payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final data = _decodeBody(payload);

    return AuthSession(
      token: token,
      userId: data['userId'] is int ? data['userId'] as int : null,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'member',
    );
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
