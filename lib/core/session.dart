import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_session.dart';

/// Singleton holding the current server URL + logged-in session,
/// persisted via shared_preferences.
class Session {
  Session._();
  static final Session instance = Session._();

  static const _kBaseUrl = 'base_url';
  static const _kSession = 'session_json';

  String baseUrl = '';
  UserSession? current;

  bool get isLoggedIn => current != null && current!.token.isNotEmpty;
  String get role => current?.role ?? '';

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    baseUrl = p.getString(_kBaseUrl) ?? '';
    final raw = p.getString(_kSession);
    if (raw != null && raw.isNotEmpty) {
      try {
        current = UserSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        current = null;
      }
    }
  }

  Future<void> saveBaseUrl(String url) async {
    baseUrl = _normalize(url);
    final p = await SharedPreferences.getInstance();
    await p.setString(_kBaseUrl, baseUrl);
  }

  Future<void> setSession(UserSession s) async {
    current = s;
    final p = await SharedPreferences.getInstance();
    await p.setString(_kSession, jsonEncode(s.toJson()));
  }

  Future<void> clear() async {
    current = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_kSession);
  }

  static String _normalize(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }
}
