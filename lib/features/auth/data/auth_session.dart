class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  final String token;
  final int? userId;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isEmpty ? email : name;
  }

  bool get isSuperadmin => role == 'superadmin';

  AuthSession copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? role,
  }) {
    return AuthSession(
      token: token,
      userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
    );
  }
}
