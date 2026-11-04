import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../widgets/feature_tile.dart';
import '../features.dart';

class LayananTab extends StatelessWidget {
  const LayananTab({super.key});

  @override
  Widget build(BuildContext context) {
    final role = Session.instance.role;
    final cats = categoriesFor(role);
    final feats = featuresFor(role);

    return Scaffold(
      appBar: AppBar(title: const Text('Layanan'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          for (final cat in cats) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
              child: Text(cat, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.9,
              children: [
                for (final f in feats.where((f) => f.category == cat)) FeatureTile(feature: f),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
