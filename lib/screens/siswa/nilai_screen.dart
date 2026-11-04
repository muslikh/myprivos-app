import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../services/siswa_service.dart';
import '../../widgets/async_views.dart';
import '../../widgets/class_dropdown.dart';

class NilaiScreen extends StatelessWidget {
  const NilaiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Session.instance.current!;
    final nisn = s.user['nisn']?.toString();
    final isSiswa = s.role == 'siswa' && nisn != null && nisn.isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Nilai (DKN / Rapor)')),
      body: isSiswa ? NilaiListView(nisn: nisn!) : const _NilaiBrowser(),
    );
  }
}

/// Reusable list of grades for one NISN.
class NilaiListView extends StatelessWidget {
  final String nisn;
  const NilaiListView({super.key, required this.nisn});

  @override
  Widget build(BuildContext context) {
    return AsyncList<Map<String, dynamic>>(
      key: ValueKey(nisn),
      emptyText: 'Belum ada nilai untuk siswa ini.',
      emptyIcon: Icons.grading,
      loader: () async =>
          (await SiswaService.nilai(nisn)).map((e) => Map<String, dynamic>.from(e)).toList(),
      itemBuilder: (c, n) {
        final p = n['pengetahuan'];
        final k = n['keterampilan'];
        final kkm = n['kkm'];
        final main = p ?? n['nilai'] ?? '-';
        final detail = (p != null || k != null)
            ? 'Pengetahuan: ${p ?? '-'}   •   Keterampilan: ${k ?? '-'}'
                '${kkm != null ? '   •   KKM: $kkm' : ''}'
            : (kkm != null ? 'KKM: $kkm' : null);
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${n['semester'] ?? '-'}', style: const TextStyle(fontSize: 12))),
            title: Text('${n['mapel'] ?? 'Mata Pelajaran'}'),
            subtitle: detail != null ? Text(detail, style: const TextStyle(fontSize: 12)) : null,
            trailing: Text('$main', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        );
      },
    );
  }
}

/// Admin/guru: pick a class, then a student, then view grades. No typing.
class _NilaiBrowser extends StatefulWidget {
  const _NilaiBrowser();
  @override
  State<_NilaiBrowser> createState() => _NilaiBrowserState();
}

class _NilaiBrowserState extends State<_NilaiBrowser> {
  String? _kelas;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClassDropdown(onSelected: (k) => setState(() => _kelas = k)),
        Expanded(
          child: _kelas == null
              ? const EmptyState(text: 'Pilih kelas untuk melihat daftar siswa.', icon: Icons.class_outlined)
              : AsyncList<Map<String, dynamic>>(
                  key: ValueKey(_kelas),
                  emptyText: 'Tidak ada siswa di kelas ini.',
                  emptyIcon: Icons.people_outline,
                  loader: () async => (await SiswaService.students(kelas: _kelas))
                      .map((e) => Map<String, dynamic>.from(e))
                      .toList(),
                  itemBuilder: (c, st) => Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text('${st['nama'] ?? '-'}'),
                      subtitle: Text('NISN: ${st['nisn'] ?? '-'}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        final nisn = '${st['nisn'] ?? ''}';
                        if (nisn.isEmpty) return;
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(title: Text('${st['nama'] ?? 'Nilai'}')),
                            body: NilaiListView(nisn: nisn),
                          ),
                        ));
                      },
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
