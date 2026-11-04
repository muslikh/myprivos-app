import '../core/api_client.dart';

class TamuService {
  static Future<List<dynamic>> list() async {
    final r = await ApiClient.instance.get('/tamu');
    return r.list;
  }

  static Future<Map<String, dynamic>> store({
    required String namaTamu,
    String? instansi,
    String? noHp,
    required String bertemuDengan,
    required String keperluan,
    String? platNomor,
  }) async {
    final r = await ApiClient.instance.post('/tamu', body: {
      'nama_tamu': namaTamu,
      'instansi': instansi,
      'no_hp': noHp,
      'bertemu_dengan': bertemuDengan,
      'keperluan': keperluan,
      'plat_nomor': platNomor,
    });
    return r.map;
  }

  static Future<void> checkOut(dynamic id) async {
    await ApiClient.instance.post('/tamu/$id/checkout');
  }
}
