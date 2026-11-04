import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import 'update_service.dart';

/// Checks for a newer APK and, if found, shows a popup. On confirm it
/// downloads the APK itself (with progress) and launches the system
/// installer via open_filex. Falls back to opening the link in a browser
/// on non-Android platforms.
class AppUpdater {
  static bool _checkedThisSession = false;

  static Future<void> maybePrompt(BuildContext context, {bool force = false}) async {
    if (_checkedThisSession && !force) return;
    _checkedThisSession = true;

    final result = await UpdateService.check();
    if (!result.available || result.info == null) return;
    if (!context.mounted) return;

    final info = result.info!;
    await showDialog(
      context: context,
      barrierDismissible: !info.mandatory,
      builder: (ctx) => AlertDialog(
        title: const Text('Pembaruan tersedia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versi baru ${info.latestVersion} (build ${info.latestBuild}) tersedia.'),
            if (info.notes.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(info.notes, style: const TextStyle(fontSize: 13)),
            ],
          ],
        ),
        actions: [
          if (!info.mandatory)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Nanti'),
            ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _download(context, info);
            },
            child: const Text('Perbarui Sekarang'),
          ),
        ],
      ),
    );
  }

  static Future<void> _download(BuildContext context, UpdateInfo info) async {
    bool isAndroid = false;
    try {
      isAndroid = Platform.isAndroid;
    } catch (_) {}

    if (!isAndroid) {
      final uri = Uri.tryParse(info.apkUrl);
      if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    final progress = ValueNotifier<double>(0);
    final status = ValueNotifier<String>('Mempersiapkan...');
    bool closed = false;
    void closeDialog() {
      if (!closed && context.mounted) {
        closed = true;
        Navigator.of(context, rootNavigator: true).pop();
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Mengunduh pembaruan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: progress,
              builder: (c, v, _) => LinearProgressIndicator(value: v > 0 ? v : null),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: status,
              builder: (c, t, _) => Text(t, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );

    final client = http.Client();
    try {
      final dir = await getExternalStorageDirectory() ?? await getTemporaryDirectory();
      final path = '${dir.path}/my-privos-update.apk';
      final sink = File(path).openWrite();

      final req = http.Request('GET', Uri.parse(info.apkUrl));
      final resp = await client.send(req);
      if (resp.statusCode != 200) {
        throw 'HTTP ${resp.statusCode}';
      }
      final total = resp.contentLength ?? 0;
      int received = 0;

      await resp.stream.forEach((chunk) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          progress.value = received / total;
          status.value = 'Mengunduh... ${(progress.value * 100).toStringAsFixed(0)}%';
        } else {
          status.value = 'Mengunduh... ${(received / 1024 / 1024).toStringAsFixed(1)} MB';
        }
      });
      await sink.flush();
      await sink.close();

      status.value = 'Membuka pemasang...';
      final res = await OpenFilex.open(path, type: 'application/vnd.android.package-archive');
      closeDialog();
      if (res.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak bisa membuka pemasang: ${res.message}. Aktifkan "Install unknown apps".')),
        );
      }
    } catch (e) {
      closeDialog();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunduh pembaruan: $e'), backgroundColor: Colors.red.shade700),
        );
      }
    } finally {
      client.close();
    }
  }
}
