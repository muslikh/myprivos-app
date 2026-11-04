import '../core/api_client.dart';

class TamuService {
  static Future<List<dynamic>> list() async {
    final r = await ApiClient.instance.get('/tamu');
    return r.list;
  }

  static Future<Map<String, dynamic>> store({
    required String namaTamu,
    String? alamat,
    String? noHp,
    required String pesan,
  }) async {
    final r = await ApiClient.instance.post('/tamu', body: {
      'nama_tamu': namaTamu,
      'alamat_tamu': alamat,
      'nohp_tamu': noHp,
      'pesan_tamu': pesan,
    });
    return r.map;
  }
}
