import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/api_response.dart';
import 'session.dart';

/// Thin HTTP wrapper: builds URLs from the stored server base + /api/v2,
/// attaches the Bearer token, and parses the JSON envelope.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Session.instance.baseUrl;
    if (base.isEmpty) {
      throw ApiException('Server URL belum diatur. Isi di layar login.');
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final full = '$base${AppConfig.apiPrefix}$cleanPath';
    final uri = Uri.parse(full);
    if (query == null || query.isEmpty) return uri;
    final qp = <String, String>{};
    query.forEach((k, v) {
      if (v != null) qp[k] = '$v';
    });
    return uri.replace(queryParameters: {...uri.queryParameters, ...qp});
  }

  Map<String, String> _headers({bool auth = true, bool json = true}) {
    final h = <String, String>{'Accept': 'application/json'};
    if (json) h['Content-Type'] = 'application/json';
    final tok = Session.instance.current?.token;
    if (auth && tok != null && tok.isNotEmpty) {
      h['Authorization'] = 'Bearer $tok';
    }
    return h;
  }

  Future<ApiResponse> get(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    return _send(() => http.get(_uri(path, query), headers: _headers(auth: auth)));
  }

  Future<ApiResponse> post(String path,
      {Map<String, dynamic>? body, bool auth = true}) async {
    return _send(() => http.post(_uri(path),
        headers: _headers(auth: auth), body: jsonEncode(body ?? {})));
  }

  Future<ApiResponse> _send(Future<http.Response> Function() run) async {
    http.Response res;
    try {
      res = await run().timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw ApiException('Koneksi timeout. Cek jaringan / server.');
    } catch (e) {
      throw ApiException('Gagal terhubung ke server: $e');
    }

    Map<String, dynamic> decoded;
    try {
      final body = res.body.isEmpty ? '{}' : res.body;
      final parsed = jsonDecode(body);
      decoded = parsed is Map<String, dynamic>
          ? parsed
          : {'success': false, 'message': 'Respons tidak dikenali', 'code': res.statusCode};
    } catch (_) {
      throw ApiException('Respons server bukan JSON (HTTP ${res.statusCode}).', res.statusCode);
    }

    final api = ApiResponse.fromJson(decoded);
    if (!api.success) {
      final msg = api.message.isNotEmpty ? api.message : 'Permintaan gagal (HTTP ${res.statusCode}).';
      throw ApiException(msg, api.code != 0 ? api.code : res.statusCode);
    }
    return api;
  }
}
