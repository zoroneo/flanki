/// Information about an available software update.
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool hasUpdate;
  final String? releaseNotes;
  final String releaseUrl;
  final String? downloadUrl;
  final String? assetName;
  final int? assetSizeBytes;
  final DateTime? publishedAt;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.hasUpdate,
    this.releaseNotes,
    required this.releaseUrl,
    this.downloadUrl,
    this.assetName,
    this.assetSizeBytes,
    this.publishedAt,
  });

  @override
  String toString() =>
      'UpdateInfo(current: $currentVersion, latest: $latestVersion, hasUpdate: $hasUpdate, downloadUrl: $downloadUrl)';
}
