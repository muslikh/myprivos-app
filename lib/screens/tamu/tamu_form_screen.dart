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
  final _instansi = TextEditingController();
  final _hp = TextEditingController();
  final _bertemu = TextEditingController();
  final _keperluan = TextEditingController();
  final _plat = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    for (final c in [_nama, _instansi, _hp, _bertemu, _keperluan, _plat]) {
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
        instansi: _instansi.text.trim().isEmpty ? null : _instansi.text.trim(),
        noHp: _hp.text.trim().isEmpty ? null : _hp.text.trim(),
        bertemuDengan: _bertemu.text.trim(),
        keperluan: _keperluan.text.trim(),
        platNomor: _plat.text.trim().isEmpty ? null : _plat.text.trim(),
      );
      if (!mounted) return;
      showSnack(context, 'Tamu tercatat.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
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
            _tf(_nama, 'Nama Tamu', req: true),
            _tf(_instansi, 'Instansi (opsional)'),
            _tf(_hp, 'No. HP (opsional)', number: true),
            _tf(_bertemu, 'Bertemu dengan', req: true),
            _tf(_keperluan, 'Keperluan', req: true, lines: 2),
            _tf(_plat, 'Plat Nomor (opsional)'),
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

  Widget _tf(TextEditingController c, String label,
      {bool req = false, bool number = false, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: c,
        maxLines: lines,
        keyboardType: number ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: req ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null : null,
      ),
    );
  }
}
