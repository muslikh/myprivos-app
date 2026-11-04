import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../services/surat_service.dart';
import '../../widgets/async_views.dart';

class SuratRequestScreen extends StatefulWidget {
  const SuratRequestScreen({super.key});
  @override
  State<SuratRequestScreen> createState() => _SuratRequestScreenState();
}

class _SuratRequestScreenState extends State<SuratRequestScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nisn =
      TextEditingController(text: Session.instance.current?.user['nisn']?.toString() ?? '');
  final _keperluan = TextEditingController();
  List<Map<String, dynamic>> _templates = [];
  dynamic _templateId;
  bool _loadingTpl = true;
  bool _submitting = false;
  String? _tplError;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _nisn.dispose();
    _keperluan.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _loadingTpl = true;
      _tplError = null;
    });
    try {
      final list = await SuratService.templates();
      _templates = list.map((e) => Map<String, dynamic>.from(e)).toList();
      if (_templates.isNotEmpty) _templateId = _templates.first['id'];
    } catch (e) {
      _tplError = '$e';
    } finally {
      if (mounted) setState(() => _loadingTpl = false);
    }
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate() || _templateId == null) return;
    setState(() => _submitting = true);
    try {
      final r = await SuratService.requestSurat(
        nisn: _nisn.text.trim(),
        templateId: _templateId,
        keperluan: _keperluan.text.trim(),
      );
      if (!mounted) return;
      final nomor = r['nomor_surat'] ?? r['verifikasi_code'] ?? '';
      showSnack(context, 'Surat diajukan. $nomor');
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
      appBar: AppBar(title: const Text('Ajukan Surat')),
      body: _loadingTpl
          ? const Center(child: CircularProgressIndicator())
          : _tplError != null
              ? EmptyState(text: 'Daftar surat belum tersedia.', icon: Icons.mail_outline, onRetry: () async => _loadTemplates())
              : Form(
                  key: _form,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextFormField(
                        controller: _nisn,
                        decoration: const InputDecoration(labelText: 'NISN'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<dynamic>(
                        value: _templateId,
                        decoration: const InputDecoration(labelText: 'Jenis Surat'),
                        items: [
                          for (final t in _templates)
                            DropdownMenuItem(
                              value: t['id'],
                              child: Text('${t['nama'] ?? t['judul'] ?? t['title'] ?? 'Template ${t['id']}'}'),
                            ),
                        ],
                        onChanged: (v) => setState(() => _templateId = v),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _keperluan,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: 'Keperluan'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Ajukan'),
                      ),
                    ],
                  ),
                ),
    );
  }
}
