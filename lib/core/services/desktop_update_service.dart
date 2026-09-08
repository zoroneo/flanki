import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';
import '../models/update_info.dart';

class DesktopUpdateService {
  final http.Client _client;

  DesktopUpdateService({http.Client? client})
    : _client = client ?? http.Client();

  /// Check if current platform is a desktop platform.
  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  /// Check if current platform supports in-app updates.
  static bool get isSupported =>
      isDesktop || Platform.isAndroid || Platform.isIOS;

  /// Compare two semver-like version strings.
  /// Returns > 0 if version1 > version2, < 0 if version1 < version2, 0 if equal.
  static int compareVersions(String v1, String v2) {
    String clean(String v) =>
        v.trim().replaceFirst(RegExp(r'^v'), '').split('+')[0];
    final parts1 = clean(v1).split(RegExp(r'[\.-]'));
    final parts2 = clean(v2).split(RegExp(r'[\.-]'));

    final maxLen = parts1.length > parts2.length
        ? parts1.length
        : parts2.length;
    for (int i = 0; i < maxLen; i++) {
      final p1 = i < parts1.length ? int.tryParse(parts1[i]) ?? 0 : 0;
      final p2 = i < parts2.length ? int.tryParse(parts2[i]) ?? 0 : 0;
      if (p1 != p2) {
        return p1.compareTo(p2);
      }
    }
    return 0;
  }

  /// Open an external URL in the system browser without 3rd party plugins.
  static Future<bool> openUrl(String url) async {
    try {
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', url]);
        return true;
      } else if (Platform.isMacOS) {
        await Process.run('open', [url]);
        return true;
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [url]);
        return true;
      } else if (Platform.isAndroid) {
        const channel = MethodChannel('com.flanki.flanki/app_updater');
        await channel.invokeMethod('openUrl', {'url': url});
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Select matching asset URL for current platform.
  static Map<String, dynamic>? findPlatformAsset(List<dynamic> assets) {
    if (assets.isEmpty) return null;

    final os = Platform.operatingSystem
        .toLowerCase(); // 'windows', 'macos', 'linux', 'android', 'ios'
    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) continue;
      final name = (asset['name'] as String? ?? '').toLowerCase();

      if (os == 'windows') {
        if (name.endsWith('.exe') ||
            name.endsWith('.msi') ||
            (name.contains('win') && name.endsWith('.zip'))) {
          return asset;
        }
      } else if (os == 'macos') {
        if (name.endsWith('.dmg') ||
            (name.contains('mac') && name.endsWith('.zip'))) {
          return asset;
        }
      } else if (os == 'linux') {
        if (name.endsWith('.appimage') ||
            name.endsWith('.deb') ||
            (name.contains('linux') && name.endsWith('.tar.gz'))) {
          return asset;
        }
      } else if (os == 'android') {
        if (name.endsWith('.apk')) {
          return asset;
        }
      }
    }

    return null;
  }

  /// Query GitHub Releases for the latest version.
  Future<UpdateInfo> checkForUpdates({
    String? currentVersion,
    String? apiUrl,
  }) async {
    final current = currentVersion ?? AppConfig.version;
    final url = apiUrl ?? AppConfig.githubReleasesApiUrl;

    try {
      final response = await _client
          .get(
            Uri.parse(url),
            headers: {
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'Flanki-Desktop-Updater',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return UpdateInfo(
          currentVersion: current,
          latestVersion: current,
          hasUpdate: false,
          releaseUrl: AppConfig.githubReleasesUrl,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rawTag = data['tag_name'] as String? ?? '';
      final latest = rawTag.replaceFirst(RegExp(r'^v'), '');
      final hasUpdate = compareVersions(latest, current) > 0;
      final releaseNotes = data['body'] as String?;
      final htmlUrl =
          data['html_url'] as String? ?? AppConfig.githubReleasesUrl;
      final publishedAtStr = data['published_at'] as String?;
      final publishedAt = publishedAtStr != null
          ? DateTime.tryParse(publishedAtStr)
          : null;

      final assets = data['assets'] as List<dynamic>? ?? [];
      final matchedAsset = findPlatformAsset(assets);

      return UpdateInfo(
        currentVersion: current,
        latestVersion: latest,
        hasUpdate: hasUpdate,
        releaseNotes: releaseNotes,
        releaseUrl: htmlUrl,
        downloadUrl: matchedAsset?['browser_download_url'] as String?,
        assetName: matchedAsset?['name'] as String?,
        assetSizeBytes: matchedAsset?['size'] as int?,
        publishedAt: publishedAt,
      );
    } catch (e) {
      return UpdateInfo(
        currentVersion: current,
        latestVersion: current,
        hasUpdate: false,
        releaseUrl: AppConfig.githubReleasesUrl,
      );
    }
  }

  /// Download the update asset with progress callback (0.0 to 1.0).
  Future<String?> downloadUpdate(
    String downloadUrl, {
    String? fileName,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final name = fileName ?? p.basename(Uri.parse(downloadUrl).path);
      final saveFile = File(p.join(tempDir.path, name));

      final request = http.Request('GET', Uri.parse(downloadUrl));
      request.headers['User-Agent'] = 'Flanki-Desktop-Updater';
      final streamedResponse = await _client.send(request);

      if (streamedResponse.statusCode != 200) {
        return null;
      }

      final totalBytes = streamedResponse.contentLength ?? 0;
      var receivedBytes = 0;

      final sink = saveFile.openWrite();
      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0 && onProgress != null) {
          onProgress(receivedBytes / totalBytes);
        }
      }
      await sink.flush();
      await sink.close();

      return saveFile.path;
    } catch (e) {
      return null;
    }
  }

  /// Execute installer and close current application.
  Future<bool> installAndRestart(String filePath) async {
    try {
      final ext = p.extension(filePath).toLowerCase();
      if (Platform.isWindows) {
        if (ext == '.exe' || ext == '.msi') {
          // Launch installer detached so it continues after app exits
          await Process.start(
            filePath,
            [],
            runInShell: true,
            mode: ProcessStartMode.detached,
          );
          exit(0);
        } else {
          // Select file in explorer for user
          await Process.run('explorer.exe', ['/select,', filePath]);
          return true;
        }
      } else if (Platform.isMacOS) {
        await Process.run('open', [filePath]);
        exit(0);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [filePath]);
        exit(0);
      } else if (Platform.isAndroid) {
        const channel = MethodChannel('com.flanki.flanki/app_updater');
        await channel.invokeMethod('installApk', {'filePath': filePath});
        return true;
      }
    } catch (_) {}
    return false;
  }
}
