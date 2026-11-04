import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../services/siswa_service.dart';
import '../../widgets/async_views.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});
  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  late final TextEditingController _kelas =
      TextEditingController(text: Session.instance.current?.user['kelas']?.toString() ?? '');
  String? _query;

  @override
  void initState() {
    super.initState();
    if (_kelas.text.trim().isNotEmpty) _query = _kelas.text.trim();
  }

  @override
  void dispose() {
    _kelas.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Pelajaran')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kelas,
                    decoration: const InputDecoration(labelText: 'Kode Kelas', isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => setState(() => _query = _kelas.text.trim()),
                  child: const Text('Lihat'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _query == null || _query!.isEmpty
                ? const Center(child: Text('Masukkan kode kelas.'))
                : AsyncList<Map<String, dynamic>>(
                    key: ValueKey(_query),
                    loader: () async => (await SiswaService.jadwal(_query!))
                        .map((e) => Map<String, dynamic>.from(e))
                        .toList(),
                    emptyText: 'Jadwal kosong.',
                    itemBuilder: (c, j) => Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${j['hari']?.toString().substring(0, 1) ?? '-'}')),
                        title: Text('${j['mapel'] ?? j['nama_mapel'] ?? '-'}'),
                        subtitle: Text('${j['hari'] ?? ''}  ${j['jam_mulai'] ?? ''}-${j['jam_selesai'] ?? ''}'),
                        trailing: Text('${j['guru'] ?? j['nama_guru'] ?? ''}',
                            style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
