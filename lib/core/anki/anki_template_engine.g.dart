// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'anki_template_engine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnkiTemplate _$AnkiTemplateFromJson(Map<String, dynamic> json) => AnkiTemplate(
  ord: (json['ord'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  qfmt: json['qfmt'] as String? ?? '',
  afmt: json['afmt'] as String? ?? '',
);

Map<String, dynamic> _$AnkiTemplateToJson(AnkiTemplate instance) =>
    <String, dynamic>{
      'ord': instance.ord,
      'name': instance.name,
      'qfmt': instance.qfmt,
      'afmt': instance.afmt,
    };
