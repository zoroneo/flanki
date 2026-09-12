// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubReleaseDto _$GithubReleaseDtoFromJson(Map<String, dynamic> json) =>
    GithubReleaseDto(
      tagName: json['tag_name'] as String? ?? '',
      body: json['body'] as String?,
      htmlUrl: json['html_url'] as String? ?? '',
      publishedAt: json['published_at'] == null
          ? null
          : DateTime.parse(json['published_at'] as String),
      assets:
          (json['assets'] as List<dynamic>?)
              ?.map((e) => GithubAssetDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$GithubReleaseDtoToJson(GithubReleaseDto instance) =>
    <String, dynamic>{
      'tag_name': instance.tagName,
      'body': instance.body,
      'html_url': instance.htmlUrl,
      'published_at': instance.publishedAt?.toIso8601String(),
      'assets': instance.assets.map((e) => e.toJson()).toList(),
    };

GithubAssetDto _$GithubAssetDtoFromJson(Map<String, dynamic> json) =>
    GithubAssetDto(
      name: json['name'] as String? ?? '',
      browserDownloadUrl: json['browser_download_url'] as String? ?? '',
      size: (json['size'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$GithubAssetDtoToJson(GithubAssetDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'browser_download_url': instance.browserDownloadUrl,
      'size': instance.size,
    };
