import 'package:flutter/material.dart';
import '../../services/webmail_service.dart';
import '../../widgets/async_views.dart';

class WebmailScreen extends StatefulWidget {
  const WebmailScreen({super.key});
  @override
  State<WebmailScreen> createState() => _WebmailScreenState();
}

class _WebmailScreenState extends State<WebmailScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Webmail'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Broadcast'),
            Tab(text: 'Kirim'),
          ]),
        ),
        body: const TabBarView(
          children: [_BroadcastTab(), _ComposeTab()],
        ),
      ),
    );
  }
}

class _BroadcastTab extends StatelessWidget {
  const _BroadcastTab();
  @override
  Widget build(BuildContext context) {
    return AsyncList<Map<String, dynamic>>(
      loader: () async =>
          (await WebmailService.broadcasts()).map((e) => Map<String, dynamic>.from(e)).toList(),
      emptyText: 'Tidak ada broadcast.',
      itemBuilder: (c, b) => Card(
        child: ListTile(
          leading: const Icon(Icons.campaign_outlined),
          title: Text('${b['subject'] ?? b['judul'] ?? '-'}'),
          subtitle: Text('${b['body'] ?? b['isi'] ?? ''}',
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}

class _ComposeTab extends StatefulWidget {
  const _ComposeTab();
  @override
  State<_ComposeTab> createState() => _ComposeTabState();
}

class _ComposeTabState extends State<_ComposeTab> {
  final _form = GlobalKey<FormState>();
  final _to = TextEditingController();
  final _subject = TextEditingController();
  final _body = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _to.dispose();
    _subject.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await WebmailService.send(
        to: _to.text.trim(),
        subject: _subject.text.trim(),
        body: _body.text.trim(),
      );
      if (!mounted) return;
      showSnack(context, 'Email terkirim.');
      _to.clear();
      _subject.clear();
      _body.clear();
    } catch (e) {
      if (mounted) showSnack(context, '$e', error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _to,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Kepada (email)'),
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _subject,
            decoration: const InputDecoration(labelText: 'Subjek'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _body,
            maxLines: 6,
            decoration: const InputDecoration(labelText: 'Isi pesan'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _sending ? null : _send,
            icon: const Icon(Icons.send),
            label: Text(_sending ? 'Mengirim...' : 'Kirim'),
          ),
        ],
      ),
    );
  }
}
