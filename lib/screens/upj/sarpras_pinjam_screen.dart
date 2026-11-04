import 'package:flutter/material.dart';
import '../../services/upj_service.dart';
import '../../widgets/async_views.dart';

class SarprasPinjamScreen extends StatefulWidget {
  const SarprasPinjamScreen({super.key});
  @override
  State<SarprasPinjamScreen> createState() => _SarprasPinjamScreenState();
}

class _SarprasPinjamScreenState extends State<SarprasPinjamScreen> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _borrower = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _code.dispose();
    _borrower.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final r = await UpjService.borrow(
        itemCode: _code.text.trim(),
        borrowerName: _borrower.text.trim(),
      );
      if (!mounted) return;
      showSnack(context, r['message']?.toString().isNotEmpty == true
          ? 'Peminjaman tercatat.'
          : 'Peminjaman tercatat.');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showSnack(context, friendlyError(e), error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pinjam Sarpras')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _code,
              decoration: const InputDecoration(
                labelText: 'Kode / QR Barang',
                prefixIcon: Icon(Icons.qr_code_2),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _borrower,
              decoration: const InputDecoration(
                labelText: 'Nama Peminjam',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Catat Peminjaman'),
            ),
          ],
        ),
      ),
    );
  }
}
