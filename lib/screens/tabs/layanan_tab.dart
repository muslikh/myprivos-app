import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../features.dart';

class LayananTab extends StatelessWidget {
  const LayananTab({super.key});

  @override
  Widget build(BuildContext context) {
    final role = Session.instance.role;
    final cats = categoriesFor(role);
    final feats = featuresFor(role);

    return Column(
      children: [
        AppBar(
          title: const Text('Layanan'),
          automaticallyImplyLeading: false,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              for (final cat in cats) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
                  child: Text(cat,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.95,
                  children: [
                    for (final f in feats.where((f) => f.category == cat))
                      _ServiceTile(feature: f),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final Feature feature;
  const _ServiceTile({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: feature.builder)),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: feature.color.withOpacity(0.14),
                child: Icon(feature.icon, color: feature.color),
              ),
              const SizedBox(height: 8),
              Text(feature.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
