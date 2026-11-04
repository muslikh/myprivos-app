import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../services/siswa_service.dart';
import '../../widgets/async_views.dart';
import '../../widgets/class_dropdown.dart';

class JadwalScreen extends StatelessWidget {
  const JadwalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Session.instance.current!;
    final kelas = s.user['kelas']?.toString();
    final isSiswa = s.role == 'siswa' && kelas != null && kelas.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Pelajaran')),
      body: isSiswa ? JadwalListView(kelas: kelas!) : const _JadwalBrowser(),
    );
  }
}

class JadwalListView extends StatelessWidget {
  final String kelas;
  const JadwalListView({super.key, required this.kelas});

  @override
  Widget build(BuildContext context) {
    return AsyncList<Map<String, dynamic>>(
      key: ValueKey(kelas),
      emptyText: 'Belum ada jadwal untuk kelas ini.',
      emptyIcon: Icons.calendar_month,
      loader: () async =>
          (await SiswaService.jadwal(kelas)).map((e) => Map<String, dynamic>.from(e)).toList(),
      itemBuilder: (c, j) => Card(
        child: ListTile(
          leading: CircleAvatar(child: Text('${(j['hari'] ?? '-').toString().isNotEmpty ? j['hari'].toString()[0] : '-'}')),
          title: Text('${j['mapel'] ?? '-'}'),
          subtitle: Text('${j['hari'] ?? ''}   ${j['jam_mulai'] ?? ''} - ${j['jam_selesai'] ?? ''}'),
          trailing: Text('${j['guru'] ?? ''}', style: const TextStyle(fontSize: 11)),
        ),
      ),
    );
  }
}

class _JadwalBrowser extends StatefulWidget {
  const _JadwalBrowser();
  @override
  State<_JadwalBrowser> createState() => _JadwalBrowserState();
}

class _JadwalBrowserState extends State<_JadwalBrowser> {
  String? _kelas;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClassDropdown(onSelected: (k) => setState(() => _kelas = k)),
        Expanded(
          child: _kelas == null
              ? const EmptyState(text: 'Pilih kelas untuk melihat jadwal.', icon: Icons.class_outlined)
              : JadwalListView(kelas: _kelas!),
        ),
      ],
    );
  }
}
