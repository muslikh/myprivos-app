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
        loader: () async =>
            (await TamuService.list()).map((e) => Map<String, dynamic>.from(e)).toList(),
        emptyText: 'Belum ada tamu.',
        itemBuilder: (c, t) {
          final status = '${t['status'] ?? ''}';
          final selesai = status.toLowerCase().contains('selesai') || t['waktu_keluar'] != null;
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: selesai ? Colors.grey.shade300 : null,
                child: const Icon(Icons.person),
              ),
              title: Text('${t['nama_tamu'] ?? '-'}'),
              subtitle: Text('${t['instansi'] ?? '-'}\nBertemu: ${t['bertemu_dengan'] ?? '-'} • ${t['keperluan'] ?? ''}'),
              isThreeLine: true,
              trailing: selesai
                  ? const Chip(label: Text('Selesai'))
                  : TextButton(
                      onPressed: () async {
                        try {
                          await TamuService.checkOut(t['id']);
                          if (!context.mounted) return;
                          showSnack(context, 'Check-out berhasil.');
                          setState(() => _reload++);
                        } catch (e) {
                          if (context.mounted) showSnack(context, '$e', error: true);
                        }
                      },
                      child: const Text('Check-out'),
                    ),
            ),
          );
        },
      ),
    );
  }
}
