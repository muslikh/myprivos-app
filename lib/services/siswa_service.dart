import '../core/api_client.dart';

class SiswaService {
  static Future<List<dynamic>> nilai(String nisn) async {
    final r = await ApiClient.instance.get('/nilai', query: {'nisn': nisn});
    return r.list;
  }

  static Future<List<dynamic>> jadwal(String kelas) async {
    final r = await ApiClient.instance.get('/jadwal', query: {'kelas': kelas});
    return r.list;
  }

  static Future<Map<String, dynamic>> kelulusan(String identifier) async {
    final r = await ApiClient.instance.get('/kelulusan', query: {'nisn': identifier});
    return r.map;
  }
}
