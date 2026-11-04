class UserSession {
  final String token;
  final String role; // admin | guru | siswa
  final Map<String, dynamic> user;

  UserSession({required this.token, required this.role, required this.user});

  String get displayName =>
      (user['nama'] ?? user['name'] ?? user['username'] ?? 'Pengguna').toString();

  Map<String, dynamic> toJson() => {'token': token, 'role': role, 'user': user};

  factory UserSession.fromJson(Map<String, dynamic> j) => UserSession(
        token: j['token']?.toString() ?? '',
        role: j['role']?.toString() ?? '',
        user: j['user'] is Map ? Map<String, dynamic>.from(j['user']) : {},
      );
}
