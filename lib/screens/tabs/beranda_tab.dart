import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../widgets/feature_tile.dart';
import '../features.dart';

class BerandaTab extends StatelessWidget {
  final VoidCallback onOpenLayanan;
  const BerandaTab({super.key, required this.onOpenLayanan});

  String _roleLabel(String r) =>
      {'admin': 'Administrator', 'guru': 'Guru / Pegawai', 'siswa': 'Siswa'}[r] ?? r;

  @override
  Widget build(BuildContext context) {
    final s = Session.instance.current!;
    final scheme = Theme.of(context).colorScheme;
    final quick = featuresFor(s.role).take(6).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primary, scheme.primary.withOpacity(0.78)],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white,
                  child: Text(
                    s.displayName.isNotEmpty ? s.displayName[0].toUpperCase() : '?',
                    style: TextStyle(color: scheme.primary, fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selamat datang,',
                          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                      Text(s.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_roleLabel(s.role),
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Akses Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(onPressed: onOpenLayanan, child: const Text('Semua')),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            delegate: SliverChildBuilderDelegate(
              (c, i) => FeatureTile(feature: quick[i]),
              childCount: quick.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: scheme.primaryContainer,
                  child: Icon(Icons.school, color: scheme.onPrimaryContainer),
                ),
                title: const Text('SMK Negeri 1 Prigen'),
                subtitle: const Text('Kabupaten Pasuruan'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
