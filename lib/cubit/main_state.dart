part of 'main_cubit.dart';

class MainState extends Equatable {
  const MainState({
    this.allPreferences = const [],
    this.menuImages = const [],
    this.isFileLoading = false,
    this.isResponseLoading = false,
    this.response,
    this.error = '',
  });

  final List<String> allPreferences;
  final List<UploadingMenuImageItem> menuImages;
  final bool isFileLoading;
  final bool isResponseLoading;
  final SuggestionResponse? response;
  final String error;

  // copyWith
  MainState copyWith({
    List<String>? allPreferences,
    List<UploadingMenuImageItem>? menuImages,
    bool? isFileLoading,
    bool? isResponseLoading,
    ValueWrapper<SuggestionResponse>? response,
    String? error,
  }) =>
      MainState(
        allPreferences: allPreferences ?? this.allPreferences,
        menuImages: menuImages ?? this.menuImages,
        isFileLoading: isFileLoading ?? this.isFileLoading,
        isResponseLoading: isResponseLoading ?? this.isResponseLoading,
        response: response != null ? response.value : this.response,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [
        allPreferences,
        menuImages,
        isFileLoading,
        isResponseLoading,
        response,
        error,
      ];
}

class UploadingMenuImageItem with EquatableMixin {
  final XFile file;
  final String uploadedUrl;

  UploadingMenuImageItem({
    required this.file,
    required this.uploadedUrl,
  });

  // copyWith
  UploadingMenuImageItem copyWith({
    XFile? file,
    String? uploadedUrl,
    bool? isUploading,
  }) =>
      UploadingMenuImageItem(
        file: file ?? this.file,
        uploadedUrl: uploadedUrl ?? this.uploadedUrl,
      );

  @override
  List<Object?> get props => [
        file,
        uploadedUrl,
      ];
}
