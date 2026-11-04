import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';
import '../core/api_client.dart';

class UpdateInfo {
  final String latestVersion;
  final int latestBuild;
  final String apkUrl;
  final bool mandatory;
  final String notes;

  UpdateInfo({
    required this.latestVersion,
    required this.latestBuild,
    required this.apkUrl,
    required this.mandatory,
    required this.notes,
  });

  factory UpdateInfo.fromMap(Map<String, dynamic> m) => UpdateInfo(
        latestVersion: (m['latest_version'] ?? m['version'] ?? '').toString(),
        latestBuild: int.tryParse('${m['latest_build'] ?? m['build'] ?? 0}') ?? 0,
        apkUrl: (m['apk_url'] ?? m['url'] ?? '').toString(),
        mandatory: m['mandatory'] == true || '${m['mandatory']}' == '1',
        notes: (m['notes'] ?? m['catatan'] ?? '').toString(),
      );
}

class UpdateCheckResult {
  final bool available;
  final UpdateInfo? info;
  final int currentBuild;
  UpdateCheckResult(this.available, this.info, this.currentBuild);
}

class UpdateService {
  /// Checks the backend for a newer build. Endpoint: GET /api/v2/app/version
  static Future<UpdateCheckResult> check() async {
    int currentBuild = 0;
    try {
      final pkg = await PackageInfo.fromPlatform();
      currentBuild = int.tryParse(pkg.buildNumber) ?? 0;
    } catch (_) {}

    try {
      final res = await ApiClient.instance.get('/app/version', auth: false);
      final info = UpdateInfo.fromMap(res.map);
      final isAndroid = !kIsWebFallback && Platform.isAndroid;
      final available =
          isAndroid && info.apkUrl.isNotEmpty && info.latestBuild > currentBuild;
      return UpdateCheckResult(available, info, currentBuild);
    } catch (_) {
      return UpdateCheckResult(false, null, currentBuild);
    }
  }
}

// Platform.isAndroid throws on web; guard without importing dart:html.
const bool kIsWebFallback = bool.fromEnvironment('dart.library.html', defaultValue: false);
