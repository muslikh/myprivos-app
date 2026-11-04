import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../services/auth_service.dart';
import '../../services/app_updater.dart';
import '../../widgets/async_views.dart';
import '../login_screen.dart';

class ProfilTab extends StatelessWidget {
  const ProfilTab({super.key});

  String _roleLabel(String r) {
    switch (r) {
      case 'admin':
        return 'Administrator';
      case 'guru':
        return 'Guru / Pegawai';
      case 'siswa':
        return 'Siswa';
      default:
        return r;
    }
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Keluar')),
        ],
      ),
    );
    if (ok != true) return;
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final s = Session.instance.current!;
    final scheme = Theme.of(context).colorScheme;
    final entries = s.user.entries
        .where((e) => e.value != null && '${e.value}'.isNotEmpty && e.key != 'foto')
        .toList();

    return Column(
      children: [
        AppBar(title: const Text('Profil'), automaticallyImplyLeading: false),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: scheme.primaryContainer,
                      child: Text(
                        s.displayName.isNotEmpty ? s.displayName[0].toUpperCase() : '?',
                        style: TextStyle(fontSize: 34, color: scheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(s.displayName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(_roleLabel(s.role), style: TextStyle(color: scheme.outline)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Column(
                  children: [
                    for (final e in entries)
                      ListTile(
                        dense: true,
                        title: Text(_pretty(e.key), style: TextStyle(fontSize: 12, color: scheme.outline)),
                        subtitle: Text('${e.value}', style: const TextStyle(fontSize: 14)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.system_update),
                  title: const Text('Cek Pembaruan'),
                  subtitle: const Text('Periksa versi aplikasi terbaru'),
                  onTap: () async {
                    showSnack(context, 'Memeriksa pembaruan...');
                    await AppUpdater.maybePrompt(context, force: true);
                  },
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: scheme.error),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _pretty(String key) {
    final map = {
      'nama': 'Nama',
      'nisn': 'NISN',
      'nis': 'NIS',
      'email': 'Email',
      'username': 'Username',
      'kelas': 'Kelas',
      'jurusan': 'Jurusan',
      'jabatan': 'Jabatan',
      'level': 'Level',
      'jenis_kelamin': 'Jenis Kelamin',
      'kode_kelas': 'Kode Kelas',
      'walas': 'Wali Kelas',
    };
    return map[key] ?? key.replaceAll('_', ' ');
  }
}
