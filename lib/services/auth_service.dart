import '../core/api_client.dart';
import '../core/session.dart';
import '../models/user_session.dart';

class AuthService {
  static Future<UserSession> login(String identifier, String password) async {
    final res = await ApiClient.instance
        .post('/auth/login', auth: false, body: {
      'username': identifier,
      'password': password,
    });
    final m = res.map;
    final session = UserSession(
      token: m['token']?.toString() ?? '',
      role: m['role']?.toString() ?? '',
      user: m['user'] is Map ? Map<String, dynamic>.from(m['user']) : {},
    );
    await Session.instance.setSession(session);
    return session;
  }

  static Future<void> logout() async {
    try {
      await ApiClient.instance.post('/auth/logout');
    } catch (_) {
      // ignore network errors on logout
    }
    await Session.instance.clear();
  }

  static Future<Map<String, dynamic>> me() async {
    final res = await ApiClient.instance.get('/auth/me');
    return res.map;
  }
}
