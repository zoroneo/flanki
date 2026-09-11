import 'package:json_annotation/json_annotation.dart';

part 'update_info.g.dart';

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

@JsonSerializable(explicitToJson: true)
class GithubReleaseDto {
  @JsonKey(name: 'tag_name', defaultValue: '')
  final String tagName;
  final String? body;
  @JsonKey(name: 'html_url', defaultValue: '')
  final String htmlUrl;
  @JsonKey(name: 'published_at')
  final DateTime? publishedAt;
  final List<GithubAssetDto> assets;

  const GithubReleaseDto({
    required this.tagName,
    this.body,
    this.htmlUrl = '',
    this.publishedAt,
    this.assets = const [],
  });

  factory GithubReleaseDto.fromJson(Map<String, dynamic> json) =>
      _$GithubReleaseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GithubReleaseDtoToJson(this);
}

@JsonSerializable()
class GithubAssetDto {
  @JsonKey(defaultValue: '')
  final String name;
  @JsonKey(name: 'browser_download_url', defaultValue: '')
  final String browserDownloadUrl;
  @JsonKey(defaultValue: 0)
  final int size;

  const GithubAssetDto({
    required this.name,
    required this.browserDownloadUrl,
    required this.size,
  });

  factory GithubAssetDto.fromJson(Map<String, dynamic> json) =>
      _$GithubAssetDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GithubAssetDtoToJson(this);
}
