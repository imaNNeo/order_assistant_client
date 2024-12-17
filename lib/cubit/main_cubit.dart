import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_assistant/data/main_data_source.dart';
import 'package:order_assistant/entity/suggestion_response.dart';
import 'package:order_assistant/entity/value_wrapper.dart';
import 'package:order_assistant/helper_functions.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  static const maxFiles = 3;

  MainCubit() : super(MainState()) {
    _initialize();
  }

  void _initialize() async {
    final foodPreferences = await MainDataSource.getAllFoodPreferences();
    emit(state.copyWith(
      allPreferences: foodPreferences,
    ));
  }

  void _emitError(String error) {
    emit(state.copyWith(error: error));
    emit(state.copyWith(error: ''));
  }

  void addFoodPreference(String preference) async {
    await MainDataSource.addNewFoodPreference(preference);
    final foodPreferences = await MainDataSource.getAllFoodPreferences();
    emit(state.copyWith(allPreferences: foodPreferences));
  }

  void addNewImage() async {
    emit(state.copyWith(isFileLoading: true));
    try {
      final photo = await HelperFunctions.loadOrTakePhoto();
      if (photo == null) {
        emit(state.copyWith(isFileLoading: false));
        return;
      }
      final uri = await MainDataSource().uploadImage(
        await photo.readAsBytes(),
        photo.name,
        photo.mimeType,
      );
      emit(state.copyWith(
        isFileLoading: false,
        menuImages: [
          ...state.menuImages,
          UploadingMenuImageItem(
            file: photo,
            uploadedUrl: uri,
          ),
        ],
      ));
    } catch (e, stack) {
      _emitError('Error: $stack');
      emit(state.copyWith(isFileLoading: false));
    }
  }

  void onSuggestMeClicked() async {
    if (state.menuImages.isEmpty) {
      _emitError('Please add at least one menu image');
      return;
    }

    if (state.isResponseLoading) {
      return;
    }

    if (state.isFileLoading) {
      return;
    }

    emit(state.copyWith(isResponseLoading: true));
    try {
      final result = await MainDataSource().requestSuggestion(
        preferences: state.allPreferences,
        menuImageUrls: state.menuImages.map((e) => e.uploadedUrl).toList(),
        customPrompt: '',
      );

      emit(state.copyWith(
        response: ValueWrapper(result),
        isResponseLoading: false,
      ));
      emit(state.copyWith(
        response: ValueWrapper.nullValue(),
      ));
    } catch (e) {
      _emitError('Error: $e');
      emit(state.copyWith(isResponseLoading: false));
    }
  }

  void removeFoodPreference(String preference) async {
    await MainDataSource.removeFoodPreference(preference);
    final foodPreferences = await MainDataSource.getAllFoodPreferences();
    emit(state.copyWith(allPreferences: foodPreferences));
  }
}
