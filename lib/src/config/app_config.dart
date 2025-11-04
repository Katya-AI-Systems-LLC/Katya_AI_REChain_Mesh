class AppConfig {
  static const String aiProvider =
      String.fromEnvironment('AI_PROVIDER', defaultValue: 'local');
  static const String openaiApiKey =
      String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const String meshAdapter =
      String.fromEnvironment('MESH_ADAPTER', defaultValue: 'emulated');
}
