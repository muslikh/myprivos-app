import '../core/api_client.dart';

class SuratService {
  static Future<List<dynamic>> templates() async {
    final r = await ApiClient.instance.get('/surat/templates');
    return r.list;
  }

  static Future<Map<String, dynamic>> requestSurat({
    required String nisn,
    required dynamic templateId,
    required String keperluan,
  }) async {
    final r = await ApiClient.instance.post('/surat/request', body: {
      'nisn': nisn,
      'template_id': templateId,
      'keperluan': keperluan,
    });
    return r.map;
  }

  static Future<Map<String, dynamic>> verify(String code) async {
    final r = await ApiClient.instance.get('/surat/verify/$code');
    return r.map;
  }
}
