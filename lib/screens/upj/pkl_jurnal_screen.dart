import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/upj_service.dart';
import '../../widgets/async_views.dart';

class PklJurnalScreen extends StatefulWidget {
  const PklJurnalScreen({super.key});
  @override
  State<PklJurnalScreen> createState() => _PklJurnalScreenState();
}

class _PklJurnalScreenState extends State<PklJurnalScreen> {
  final _form = GlobalKey<FormState>();
  final _placement = TextEditingController();
  final _activities = TextEditingController();
  DateTime _date = DateTime.now();
  bool _submitting = false;

  @override
  void dispose() {
    _placement.dispose();
    _activities.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await UpjService.submitPklJournal(
        placementId: _placement.text.trim(),
        date: DateFormat('yyyy-MM-dd').format(_date),
        activities: _activities.text.trim(),
      );
      if (!mounted) return;
      showSnack(context, 'Jurnal PKL terkirim.');
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
      appBar: AppBar(title: const Text('Jurnal PKL')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _placement,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'ID Penempatan PKL'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Tanggal'),
                child: Text(DateFormat('EEEE, dd MMM yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _activities,
              maxLines: 5,
              decoration: const InputDecoration(labelText: 'Kegiatan hari ini'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Kirim Jurnal'),
            ),
          ],
        ),
      ),
    );
  }
}
