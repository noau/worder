import 'package:json_annotation/json_annotation.dart';

part 'llm_config.g.dart';

@JsonSerializable()
class LLMConfig {
  final String baseURL;
  final String modelName;
  final String apiKey;

  const LLMConfig({
    required this.baseURL,
    required this.modelName,
    required this.apiKey,
  });

  bool get isEmpty => baseURL.isEmpty || modelName.isEmpty || apiKey.isEmpty;

  factory LLMConfig.fromJson(Map<String, dynamic> json) =>
      _$LLMConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LLMConfigToJson(this);

  static const LLMConfig empty = LLMConfig(
    baseURL: "",
    modelName: "",
    apiKey: "",
  );
}