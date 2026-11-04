import '../core/api_client.dart';

class PegawaiService {
  static Future<List<dynamic>> list({String? search}) async {
    final r = await ApiClient.instance.get('/pegawai', query: {'search': search});
    return r.list;
  }

  static Future<void> presensiKelas({
    required String namaGuru,
    String? nip,
    required String kelas,
    required String mapel,
    String? materi,
    int jumlahHadir = 30,
  }) async {
    await ApiClient.instance.post('/pegawai/presensi-kelas', body: {
      'nama_guru': namaGuru,
      'nip': nip,
      'kelas': kelas,
      'mapel': mapel,
      'materi': materi,
      'jumlah_siswa_hadir': jumlahHadir,
    });
  }
}
