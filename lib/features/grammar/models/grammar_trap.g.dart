// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_trap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrammarTrap _$GrammarTrapFromJson(Map<String, dynamic> json) => GrammarTrap(
  trap: json['trap'] as String? ?? '',
  exampleWrong: json['exampleWrong'] as String? ?? '',
  exampleRight: json['exampleRight'] as String? ?? '',
  note: json['note'] as String? ?? '',
);

Map<String, dynamic> _$GrammarTrapToJson(GrammarTrap instance) =>
    <String, dynamic>{
      'trap': instance.trap,
      'exampleWrong': instance.exampleWrong,
      'exampleRight': instance.exampleRight,
      'note': instance.note,
    };
