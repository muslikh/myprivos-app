import 'package:flutter/material.dart';
import '../../services/wordpress_service.dart';
import '../../widgets/async_views.dart';

class BeritaScreen extends StatelessWidget {
  const BeritaScreen({super.key});

  String _strip(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Berita Sekolah')),
      body: AsyncList<Map<String, dynamic>>(
        loader: () async =>
            (await WordPressService.posts()).map((e) => Map<String, dynamic>.from(e)).toList(),
        emptyText: 'Belum ada berita.',
        itemBuilder: (c, p) {
          final title = (p['title'] is Map) ? p['title']['rendered'] : p['title'];
          final excerptRaw = (p['excerpt'] is Map) ? p['excerpt']['rendered'] : (p['excerpt'] ?? '');
          return Card(
            child: ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(_strip('${title ?? '-'}')),
              subtitle: Text(_strip('${excerptRaw ?? ''}'),
                  maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
          );
        },
      ),
    );
  }
}
