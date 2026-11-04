import 'package:flutter/material.dart';
import '../../services/tamu_service.dart';
import '../../widgets/async_views.dart';

class TamuFormScreen extends StatefulWidget {
  const TamuFormScreen({super.key});
  @override
  State<TamuFormScreen> createState() => _TamuFormScreenState();
}

class _TamuFormScreenState extends State<TamuFormScreen> {
  final _form = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _alamat = TextEditingController();
  final _hp = TextEditingController();
  final _pesan = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    for (final c in [_nama, _alamat, _hp, _pesan]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await TamuService.store(
        namaTamu: _nama.text.trim(),
        alamat: _alamat.text.trim().isEmpty ? null : _alamat.text.trim(),
        noHp: _hp.text.trim().isEmpty ? null : _hp.text.trim(),
        pesan: _pesan.text.trim(),
      );
      if (!mounted) return;
      showSnack(context, 'Kunjungan tamu tercatat.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tamu Baru')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tf(_nama, 'Nama Tamu', Icons.person_outline, req: true),
            _tf(_alamat, 'Alamat / Instansi', Icons.location_on_outlined),
            _tf(_hp, 'No. HP', Icons.phone_outlined, number: true),
            _tf(_pesan, 'Keperluan / Pesan', Icons.message_outlined, req: true, lines: 3),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tf(TextEditingController c, String label, IconData icon,
      {bool req = false, bool number = false, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        maxLines: lines,
        keyboardType: number ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
        validator: req ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null : null,
      ),
    );
  }
}
