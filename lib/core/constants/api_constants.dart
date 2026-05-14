class ApiConstants {
  ApiConstants._();

  // Android emulator: http://10.0.2.2:3000
  // Physical device: use the backend computer LAN IP.
  static const String baseUrl = 'http://10.241.188.77:3000';

  static Uri uri(String path) => Uri.parse('$baseUrl$path');
}
