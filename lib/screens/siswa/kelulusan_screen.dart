import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../services/siswa_service.dart';
import '../../widgets/async_views.dart';

class KelulusanScreen extends StatefulWidget {
  const KelulusanScreen({super.key});
  @override
  State<KelulusanScreen> createState() => _KelulusanScreenState();
}

class _KelulusanScreenState extends State<KelulusanScreen> {
  late final TextEditingController _id =
      TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    _id.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      _result = await SiswaService.kelulusan(_id.text.trim());
    } catch (e) {
      _error = 'Data kelulusan belum tersedia.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status Kelulusan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _id,
              decoration: const InputDecoration(labelText: 'No. Ujian', prefixIcon: Icon(Icons.confirmation_number_outlined)),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _check,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Cek Kelulusan'),
            ),
            const SizedBox(height: 20),
            if (_error != null) EmptyState(text: _error!, icon: Icons.search_off, onRetry: () async => _check()),
            if (_result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final e in _result!.entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: 120,
                                  child: Text('${e.key}',
                                      style: const TextStyle(fontWeight: FontWeight.w600))),
                              Expanded(child: Text('${e.value}')),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
