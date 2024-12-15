part of 'main_cubit.dart';

class MainState extends Equatable {
  const MainState({
    this.allPreferences = const [],
    this.apiKey = '',
    this.menuImages = const [],
    this.isFileLoading = false,
    this.isResponseLoading = false,
    this.response = '',
    this.error = '',
  });

  final List<String> allPreferences;
  final String apiKey;
  final List<(XFile, String)> menuImages;
  final bool isFileLoading;
  final bool isResponseLoading;
  final String response;
  final String error;

  // copyWith
  MainState copyWith({
    List<String>? allPreferences,
    String? apiKey,
    List<(XFile, String)>? menuImages,
    bool? isFileLoading,
    bool? isResponseLoading,
    String? response,
    String? error,
  }) => MainState(
    allPreferences: allPreferences ?? this.allPreferences,
    apiKey: apiKey ?? this.apiKey,
    menuImages: menuImages ?? this.menuImages,
    isFileLoading: isFileLoading ?? this.isFileLoading,
    isResponseLoading: isResponseLoading ?? this.isResponseLoading,
    response: response ?? this.response,
    error: error ?? this.error,
  );

  @override
  List<Object> get props => [
        allPreferences,
        apiKey,
        menuImages,
        isFileLoading,
        isResponseLoading,
        response,
    error,
      ];
}
