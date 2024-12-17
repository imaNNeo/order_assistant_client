import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:order_assistant/data/urls.dart';
import 'package:order_assistant/entity/suggestion_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainDataSource {
  static final MainDataSource _singleton = MainDataSource._internal();

  factory MainDataSource() {
    return _singleton;
  }

  MainDataSource._internal();

  static const _foodPreferencesKey = 'food_preferences';

  final _dio = Dio(
    BaseOptions(
      headers: {
        'Authorization': 'Bearer $_serverKey',
      },
    ),
  )..interceptors.add(
      LogInterceptor(responseBody: true, requestBody: true),
    );

  Future<String> uploadImage(
    Uint8List bytes,
    String name,
    String? mimeType,
  ) async {
    final response = await _dio.post(
      Urls.uploadImageUrl,
      data: FormData.fromMap({
        'image_file': MultipartFile.fromBytes(
          bytes,
          filename: name,
          contentType: DioMediaType.parse(mimeType ?? 'image/jpeg'),
        ),
      }),
    );
    final uri = response.data['file_uri'] as String;
    return uri;
  }

  final Map<
      ({
        List<String> preferences,
        List<String> menuImageUrls,
        String? customPrompt
      }),
      SuggestionResponse> _cachedResponses = {};

  Future<SuggestionResponse> requestSuggestion({
    required List<String> preferences,
    required List<String> menuImageUrls,
    required String? customPrompt,
  }) async {

    final cacheKey = (
      preferences: preferences,
      menuImageUrls: menuImageUrls,
      customPrompt: customPrompt,
    );
    if (_cachedResponses.containsKey(cacheKey)) {
      return _cachedResponses[cacheKey]!;
    }

    final rawResponse = await _dio.post(Urls.suggestUrl, data: {
      'preferences': preferences,
      'menu_images': menuImageUrls,
      'extra_note': customPrompt,
    });
    final response = SuggestionResponse.fromJson(rawResponse.data);
    _cachedResponses[cacheKey] = response;
    return response;
  }

  static Future<void> addNewFoodPreference(String newPreference) async {
    final sharedPref = await SharedPreferences.getInstance();
    sharedPref.setStringList(_foodPreferencesKey, [
      newPreference,
      ...sharedPref.getStringList(_foodPreferencesKey) ?? [],
    ]);
  }

  static Future<List<String>> getAllFoodPreferences() async {
    final sharedPref = await SharedPreferences.getInstance();
    return sharedPref.getStringList(_foodPreferencesKey) ?? [];
  }

  static removeFoodPreference(String preference) async {
    final sharedPref = await SharedPreferences.getInstance();
    final foodPreferences = sharedPref.getStringList(_foodPreferencesKey) ?? [];
    foodPreferences.remove(preference);
    await sharedPref.setStringList(_foodPreferencesKey, foodPreferences);
  }

  static const String _serverKey = String.fromEnvironment(
    'SERVER_KEY',
    defaultValue: "PROD",
  );
}
