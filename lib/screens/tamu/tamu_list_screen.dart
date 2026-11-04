import 'package:flutter/material.dart';
import '../../services/tamu_service.dart';
import '../../widgets/async_views.dart';
import 'tamu_form_screen.dart';

class TamuListScreen extends StatefulWidget {
  const TamuListScreen({super.key});
  @override
  State<TamuListScreen> createState() => _TamuListScreenState();
}

class _TamuListScreenState extends State<TamuListScreen> {
  int _reload = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buku Tamu')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Tamu Baru'),
        onPressed: () async {
          final ok = await Navigator.of(context)
              .push<bool>(MaterialPageRoute(builder: (_) => const TamuFormScreen()));
          if (ok == true) setState(() => _reload++);
        },
      ),
      body: AsyncList<Map<String, dynamic>>(
        key: ValueKey(_reload),
        emptyText: 'Belum ada tamu yang tercatat.',
        emptyIcon: Icons.how_to_reg_outlined,
        loader: () async =>
            (await TamuService.list()).map((e) => Map<String, dynamic>.from(e)).toList(),
        itemBuilder: (c, t) => Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text('${t['nama_tamu'] ?? '-'}'),
            subtitle: Text(
              '${t['alamat_tamu'] ?? ''}\n${t['pesan_tamu'] ?? ''}',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            isThreeLine: true,
            trailing: Text(
              _fmt('${t['waktu'] ?? ''}'),
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    return '${d.day}/${d.month}\n${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
