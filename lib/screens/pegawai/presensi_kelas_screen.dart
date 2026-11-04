import 'package:flutter/material.dart';
import '../../core/session.dart';
import '../../services/pegawai_service.dart';
import '../../widgets/async_views.dart';

/// Manual class-attendance entry by a teacher (NOT GPS/QR based).
class PresensiKelasScreen extends StatefulWidget {
  const PresensiKelasScreen({super.key});
  @override
  State<PresensiKelasScreen> createState() => _PresensiKelasScreenState();
}

class _PresensiKelasScreenState extends State<PresensiKelasScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _nama =
      TextEditingController(text: Session.instance.current?.user['nama']?.toString() ?? '');
  final _nip = TextEditingController();
  final _kelas = TextEditingController();
  final _mapel = TextEditingController();
  final _materi = TextEditingController();
  final _hadir = TextEditingController(text: '30');
  bool _submitting = false;

  @override
  void dispose() {
    for (final c in [_nama, _nip, _kelas, _mapel, _materi, _hadir]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      await PegawaiService.presensiKelas(
        namaGuru: _nama.text.trim(),
        nip: _nip.text.trim().isEmpty ? null : _nip.text.trim(),
        kelas: _kelas.text.trim(),
        mapel: _mapel.text.trim(),
        materi: _materi.text.trim().isEmpty ? null : _materi.text.trim(),
        jumlahHadir: int.tryParse(_hadir.text.trim()) ?? 30,
      );
      if (!mounted) return;
      showSnack(context, 'Kehadiran kelas tercatat.');
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catat Kehadiran Kelas')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _tf(_nama, 'Nama Guru', req: true),
            _tf(_nip, 'NIP (opsional)'),
            _tf(_kelas, 'Kelas', req: true),
            _tf(_mapel, 'Mata Pelajaran', req: true),
            _tf(_materi, 'Materi diajarkan (opsional)', lines: 2),
            _tf(_hadir, 'Jumlah siswa hadir', number: true),
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
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: req ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null : null,
      ),
    );
  }
}
