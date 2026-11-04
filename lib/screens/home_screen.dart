import 'package:flutter/material.dart';
import '../core/session.dart';
import '../services/auth_service.dart';
import '../services/app_updater.dart';
import '../widgets/async_views.dart';
import 'login_screen.dart';
import 'siswa/nilai_screen.dart';
import 'siswa/jadwal_screen.dart';
import 'siswa/kelulusan_screen.dart';
import 'surat/surat_request_screen.dart';
import 'pegawai/pegawai_list_screen.dart';
import 'pegawai/presensi_kelas_screen.dart';
import 'upj/upj_items_screen.dart';
import 'upj/pkl_jurnal_screen.dart';
import 'upj/sarpras_pinjam_screen.dart';
import 'tamu/tamu_list_screen.dart';
import 'webmail/webmail_screen.dart';
import 'wordpress/berita_screen.dart';

class _Feature {
  final String title;
  final IconData icon;
  final Set<String> roles; // which roles may see it
  final WidgetBuilder builder;
  const _Feature(this.title, this.icon, this.roles, this.builder);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppUpdater.maybePrompt(context);
    });
  }

  static final List<_Feature> _all = [
    // Siswa
    _Feature('Nilai', Icons.grading, {'siswa', 'admin'}, (_) => const NilaiScreen()),
    _Feature('Jadwal', Icons.calendar_month, {'siswa', 'guru', 'admin'}, (_) => const JadwalScreen()),
    _Feature('Kelulusan', Icons.verified, {'siswa', 'admin'}, (_) => const KelulusanScreen()),
    _Feature('Ajukan Surat', Icons.mail_outline, {'siswa', 'admin'}, (_) => const SuratRequestScreen()),
    // Guru / Pegawai
    _Feature('Pegawai/GTK', Icons.badge_outlined, {'guru', 'admin'}, (_) => const PegawaiListScreen()),
    _Feature('Kehadiran Kelas', Icons.co_present, {'guru', 'admin'}, (_) => const PresensiKelasScreen()),
    // UPJ
    _Feature('Katalog UPJ', Icons.storefront, {'guru', 'admin'}, (_) => const UpjItemsScreen()),
    _Feature('Jurnal PKL', Icons.menu_book, {'siswa', 'guru', 'admin'}, (_) => const PklJurnalScreen()),
    _Feature('Pinjam Sarpras', Icons.handyman, {'guru', 'admin'}, (_) => const SarprasPinjamScreen()),
    // Admin
    _Feature('Buku Tamu', Icons.how_to_reg, {'admin', 'guru'}, (_) => const TamuListScreen()),
    _Feature('Webmail', Icons.email, {'admin'}, (_) => const WebmailScreen()),
    _Feature('Berita Sekolah', Icons.newspaper, {'siswa', 'guru', 'admin'}, (_) => const BeritaScreen()),
  ];

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final s = Session.instance.current!;
    final role = s.role;
    final features = _all.where((f) => f.roles.contains(role)).toList();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyPrivos'),
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(color: scheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Halo, ${s.displayName}',
                    style: TextStyle(
                        color: scheme.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.onPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(role.toUpperCase(),
                      style: TextStyle(color: scheme.onPrimary, fontSize: 12)),
                ),
              ],
            ),
          ),
          Expanded(
            child: features.isEmpty
                ? const Center(child: Text('Tidak ada fitur untuk peran ini.'))
                : GridView.count(
                    padding: const EdgeInsets.all(16),
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      for (final f in features)
                        _FeatureTile(
                          feature: f,
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: f.builder)),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final _Feature feature;
  final VoidCallback onTap;
  const _FeatureTile({required this.feature, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: scheme.primaryContainer,
                child: Icon(feature.icon, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(height: 8),
              Text(feature.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
