import '../core/api_client.dart';

class WordPressService {
  static Future<List<dynamic>> posts({int page = 1, String? search}) async {
    final r = await ApiClient.instance
        .get('/wordpress/posts', query: {'page': page, 'search': search});
    return r.list;
  }
}
