// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'llm_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LLMConfig _$LLMConfigFromJson(Map<String, dynamic> json) => LLMConfig(
  baseURL: json['baseURL'] as String,
  modelName: json['modelName'] as String,
  apiKey: json['apiKey'] as String,
);

Map<String, dynamic> _$LLMConfigToJson(LLMConfig instance) => <String, dynamic>{
  'baseURL': instance.baseURL,
  'modelName': instance.modelName,
  'apiKey': instance.apiKey,
};
