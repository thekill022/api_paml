import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/booking_model.dart';

class BookingRepository {
  static const _tokenKey = 'driveease_access_token';

  Future<List<BookingModel>> fetchBookings() async {
    final response = await http.get(
      ApiConstants.uri('/booking'),
      headers: await _authHeaders(),
    );

    final body = _decode(response.body);
    if (response.statusCode != 200) {
      throw BookingException(_message(body, 'Gagal mengambil booking'));
    }
    if (body is! List) return [];
    return body
        .whereType<Map<String, dynamic>>()
        .map(BookingModel.fromJson)
        .toList();
  }

  Future<AvailabilityResult> checkAvailability({
    required int katalogId,
    required String startDate,
    required String endDate,
  }) async {
    final uri = ApiConstants.uri(
      '/booking/availability?katalogId=$katalogId&startDate=$startDate&endDate=$endDate',
    );
    final response = await http.get(uri, headers: await _authHeaders());
    final body = _decode(response.body);
    if (response.statusCode != 200) {
      throw BookingException(_message(body, 'Gagal mengecek availability'));
    }
    if (body is Map<String, dynamic>) return AvailabilityResult.fromJson(body);
    throw const BookingException('Response availability tidak valid');
  }

  Future<void> createBooking({
    required int katalogId,
    required String customerName,
    required String customerPhone,
    required String startDate,
    required String endDate,
  }) async {
    final response = await http.post(
      ApiConstants.uri('/booking'),
      headers: await _jsonAuthHeaders(),
      body: jsonEncode({
        'katalogId': katalogId,
        'customerName': customerName,
        'customerPhone': customerPhone,
        'startDate': startDate,
        'endDate': endDate,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BookingException(
        _message(_decode(response.body), 'Gagal membuat booking'),
      );
    }
  }

  Future<void> returnEarly({
    required int id,
    required String actualReturnDate,
  }) async {
    final response = await http.patch(
      ApiConstants.uri('/booking/$id/return'),
      headers: await _jsonAuthHeaders(),
      body: jsonEncode({'actualReturnDate': actualReturnDate}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BookingException(
        _message(_decode(response.body), 'Gagal mengembalikan mobil'),
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
      throw const BookingException(
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

class BookingException implements Exception {
  const BookingException(this.message);

  final String message;

  @override
  String toString() => message;
}
