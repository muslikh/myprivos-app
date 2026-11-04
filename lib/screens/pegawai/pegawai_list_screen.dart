import 'package:flutter/material.dart';
import '../../services/pegawai_service.dart';
import '../../widgets/async_views.dart';

class PegawaiListScreen extends StatefulWidget {
  const PegawaiListScreen({super.key});
  @override
  State<PegawaiListScreen> createState() => _PegawaiListScreenState();
}

class _PegawaiListScreenState extends State<PegawaiListScreen> {
  final _search = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pegawai / GTK')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Cari nama / NIP',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => setState(() => _q = _search.text.trim()),
                ),
              ),
              onSubmitted: (v) => setState(() => _q = v.trim()),
            ),
          ),
          Expanded(
            child: AsyncList<Map<String, dynamic>>(
              key: ValueKey(_q),
              loader: () async => (await PegawaiService.list(search: _q.isEmpty ? null : _q))
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList(),
              emptyText: 'Tidak ada pegawai.',
              itemBuilder: (c, p) => Card(
                child: ListTile(
                  leading: CircleAvatar(
                      child: Text('${(p['nama_lengkap'] ?? p['nama'] ?? '?').toString().characters.first}')),
                  title: Text('${p['nama_lengkap'] ?? p['nama'] ?? '-'}'),
                  subtitle: Text('NIP: ${p['nip'] ?? '-'}\n${p['jabatan'] ?? ''}'),
                  isThreeLine: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
