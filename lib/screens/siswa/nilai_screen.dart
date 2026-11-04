import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../services/siswa_service.dart';
import '../../widgets/async_views.dart';

class NilaiScreen extends StatefulWidget {
  const NilaiScreen({super.key});
  @override
  State<NilaiScreen> createState() => _NilaiScreenState();
}

class _NilaiScreenState extends State<NilaiScreen> {
  late final TextEditingController _nisn =
      TextEditingController(text: Session.instance.current?.user['nisn']?.toString() ?? '');
  String? _query;

  @override
  void initState() {
    super.initState();
    if (_nisn.text.trim().isNotEmpty) _query = _nisn.text.trim();
  }

  @override
  void dispose() {
    _nisn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nilai (DKN / Rapor)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nisn,
                    decoration: const InputDecoration(labelText: 'NISN', isDense: true),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => setState(() => _query = _nisn.text.trim()),
                  child: const Text('Cari'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _query == null || _query!.isEmpty
                ? const Center(child: Text('Masukkan NISN lalu tekan Cari.'))
                : AsyncList<Map<String, dynamic>>(
                    key: ValueKey(_query),
                    loader: () async => (await SiswaService.nilai(_query!))
                        .map((e) => Map<String, dynamic>.from(e))
                        .toList(),
                    emptyText: 'Belum ada nilai.',
                    itemBuilder: (c, n) => Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${n['semester'] ?? '-'}')),
                        title: Text('Semester ${n['semester'] ?? '-'}'),
                        subtitle: const Text('Nilai rapor'),
                        trailing: Text('${n['nilai'] ?? '-'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
