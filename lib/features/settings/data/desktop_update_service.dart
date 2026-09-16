import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/dio_client.dart';
import '../models/update_info.dart';

enum AppPlatform {
  windows,
  macos,
  linux,
  android,
  ios,
  other;

  static AppPlatform get current {
    if (Platform.isWindows) return AppPlatform.windows;
    if (Platform.isMacOS) return AppPlatform.macos;
    if (Platform.isLinux) return AppPlatform.linux;
    if (Platform.isAndroid) return AppPlatform.android;
    if (Platform.isIOS) return AppPlatform.ios;
    return AppPlatform.other;
  }
}

class DesktopUpdateService {
  final Dio _dio;
  CancelToken? _cancelToken;

  DesktopUpdateService({Dio? dio}) : _dio = dio ?? DioClient.defaultInstance;

  /// Cancel any active file download.
  void cancelDownload() {
    _cancelToken?.cancel('Download cancelled by user');
    _cancelToken = null;
  }

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
        await Process.run(AppConfig.cliCmd, [
          ...AppConfig.cliCmdStartArgs,
          url,
        ]);
        return true;
      } else if (Platform.isMacOS) {
        await Process.run(AppConfig.cliOpen, [url]);
        return true;
      } else if (Platform.isLinux) {
        await Process.run(AppConfig.cliXdgOpen, [url]);
        return true;
      } else if (Platform.isAndroid) {
        const channel = MethodChannel(AppConfig.appUpdaterMethodChannel);
        await channel.invokeMethod(AppConfig.methodOpenUrl, {
          AppConfig.paramUrl: url,
        });
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Select matching asset URL for current platform.
  static Map<String, dynamic>? findPlatformAsset(
    List<dynamic> assets, {
    AppPlatform? targetPlatform,
  }) {
    if (assets.isEmpty) return null;

    final platform = targetPlatform ?? AppPlatform.current;
    for (final asset in assets) {
      if (asset is! Map<String, dynamic>) continue;
      final name = (asset['name'] as String? ?? '').toLowerCase();

      switch (platform) {
        case AppPlatform.windows:
          if (name.endsWith(AppConfig.extExe) ||
              name.endsWith(AppConfig.extMsi) ||
              (name.contains(AppConfig.tokenWin) &&
                  name.endsWith(AppConfig.extZip))) {
            return asset;
          }
          break;
        case AppPlatform.macos:
          if (name.endsWith(AppConfig.extDmg) ||
              (name.contains(AppConfig.tokenMac) &&
                  name.endsWith(AppConfig.extZip))) {
            return asset;
          }
          break;
        case AppPlatform.linux:
          if (name.endsWith(AppConfig.extAppImage) ||
              name.endsWith(AppConfig.extDeb) ||
              (name.contains(AppConfig.tokenLinux) &&
                  name.endsWith(AppConfig.extTarGz))) {
            return asset;
          }
          break;
        case AppPlatform.android:
          if (name.endsWith(AppConfig.extApk)) {
            return asset;
          }
          break;
        case AppPlatform.ios:
        case AppPlatform.other:
          break;
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
      final response = await _dio.get<dynamic>(
        url,
        options: Options(
          headers: {
            'Accept': AppConfig.githubApiAcceptHeader,
            'User-Agent': AppConfig.desktopUpdaterUserAgent,
          },
          receiveTimeout: AppConfig.updateCheckTimeout,
        ),
      );

      if (response.statusCode != 200 || response.data == null) {
        return UpdateInfo(
          currentVersion: current,
          latestVersion: current,
          hasUpdate: false,
          releaseUrl: AppConfig.githubReleasesUrl,
        );
      }

      final Map<String, dynamic> rawJson = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : jsonDecode(response.data.toString()) as Map<String, dynamic>;

      final release = GithubReleaseDto.fromJson(rawJson);
      final rawTag = release.tagName;
      final latest = rawTag.replaceFirst(RegExp(r'^v'), '');
      final hasUpdate = compareVersions(latest, current) > 0;
      final releaseNotes = release.body;
      final htmlUrl = release.htmlUrl.isNotEmpty
          ? release.htmlUrl
          : AppConfig.githubReleasesUrl;
      final publishedAt = release.publishedAt;

      final matchedAsset = findPlatformAsset(
        release.assets.map((a) => a.toJson()).toList(),
      );

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
    String? targetDirectoryPath,
    void Function(double progress)? onProgress,
  }) async {
    File? saveFile;
    try {
      final dirPath =
          targetDirectoryPath ?? (await getTemporaryDirectory()).path;
      final name = fileName ?? p.basename(Uri.parse(downloadUrl).path);
      saveFile = File(p.join(dirPath, name));

      final token = CancelToken();
      _cancelToken = token;

      final response = await _dio.download(
        downloadUrl,
        saveFile.path,
        cancelToken: token,
        options: Options(
          headers: {'User-Agent': AppConfig.desktopUpdaterUserAgent},
        ),
        onReceiveProgress: (receivedBytes, totalBytes) {
          if (totalBytes > 0 && onProgress != null) {
            onProgress(receivedBytes / totalBytes);
          }
        },
      );

      if (response.statusCode != 200) {
        if (await saveFile.exists()) {
          try {
            await saveFile.delete();
          } catch (_) {}
        }
        return null;
      }

      return saveFile.path;
    } catch (e) {
      if (saveFile != null && await saveFile.exists()) {
        try {
          await saveFile.delete();
        } catch (_) {}
      }
      return null;
    } finally {
      _cancelToken = null;
    }
  }

  /// Execute installer and close current application.
  Future<bool> installAndRestart(String filePath) async {
    try {
      final ext = p.extension(filePath).toLowerCase();
      if (Platform.isWindows) {
        if (ext == AppConfig.extExe || ext == AppConfig.extMsi) {
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
          await Process.run(AppConfig.cliExplorer, [
            AppConfig.cliSelectArg,
            filePath,
          ]);
          return true;
        }
      } else if (Platform.isMacOS) {
        await Process.run(AppConfig.cliOpen, [filePath]);
        exit(0);
      } else if (Platform.isLinux) {
        await Process.run(AppConfig.cliXdgOpen, [filePath]);
        exit(0);
      } else if (Platform.isAndroid) {
        const channel = MethodChannel(AppConfig.appUpdaterMethodChannel);
        await channel.invokeMethod(AppConfig.methodInstallApk, {
          AppConfig.paramFilePath: filePath,
        });
        return true;
      }
    } catch (_) {}
    return false;
  }
}
