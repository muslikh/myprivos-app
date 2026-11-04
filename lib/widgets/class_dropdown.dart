import 'package:flutter/material.dart';
import '../services/siswa_service.dart';

class ClassDropdown extends StatefulWidget {
  final ValueChanged<String> onSelected;
  const ClassDropdown({super.key, required this.onSelected});
  @override
  State<ClassDropdown> createState() => _ClassDropdownState();
}

class _ClassDropdownState extends State<ClassDropdown> {
  late Future<List<String>> _future;
  String? _value;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<String>> _load() async {
    try {
      final list = await SiswaService.kelasList();
      return list.map((e) => '${(e is Map ? e['kelas'] : e)}').where((s) => s.isNotEmpty).toList();
    } catch (_) {
      return <String>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          );
        }
        final items = snap.data ?? [];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Daftar kelas belum tersedia.'),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(12),
          child: DropdownButtonFormField<String>(
            value: _value,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Pilih Kelas',
              prefixIcon: Icon(Icons.class_outlined),
            ),
            items: [
              for (final k in items) DropdownMenuItem(value: k, child: Text(k)),
            ],
            onChanged: (v) {
              if (v == null) return;
              setState(() => _value = v);
              widget.onSelected(v);
            },
          ),
        );
      },
    );
  }
}
