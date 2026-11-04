import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:url_launcher/url_launcher.dart';
import 'update_service.dart';

/// Checks for a newer APK and, if found, shows a popup. On confirm it
/// downloads + installs in-app via ota_update (Android), falling back to
/// opening the link in the browser.
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
              _startDownload(context, info);
            },
            child: const Text('Perbarui Sekarang'),
          ),
        ],
      ),
    );
  }

  static Future<void> _startDownload(BuildContext context, UpdateInfo info) async {
    bool isAndroid = false;
    try {
      isAndroid = Platform.isAndroid;
    } catch (_) {}

    // Non-Android or plugin unavailable -> open link in browser.
    if (!isAndroid) {
      final uri = Uri.tryParse(info.apkUrl);
      if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    final progress = ValueNotifier<double>(0);
    final statusText = ValueNotifier<String>('Mempersiapkan unduhan...');

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
              valueListenable: statusText,
              builder: (c, t, _) => Text(t, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );

    try {
      OtaUpdate()
          .execute(info.apkUrl, destinationFilename: 'my-privos-update.apk')
          .listen((OtaEvent event) {
        switch (event.status) {
          case OtaStatus.DOWNLOADING:
            final p = double.tryParse(event.value ?? '') ?? 0;
            progress.value = p / 100.0;
            statusText.value = 'Mengunduh... ${event.value ?? '0'}%';
            break;
          case OtaStatus.INSTALLING:
            statusText.value = 'Memasang pembaruan...';
            break;
          case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
            statusText.value = 'Izin instalasi ditolak. Aktifkan "Install unknown apps".';
            break;
          case OtaStatus.DOWNLOAD_ERROR:
          case OtaStatus.INTERNAL_ERROR:
          case OtaStatus.CHECKSUM_ERROR:
          case OtaStatus.ALREADY_RUNNING_ERROR:
            statusText.value = 'Gagal mengunduh. Coba lagi nanti.';
            break;
        }
      });
    } catch (e) {
      statusText.value = 'Gagal memulai unduhan: $e';
    }
  }
}
