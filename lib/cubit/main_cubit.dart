import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_assistant/data/main_data_source.dart';

import '../helper_functions.dart';

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {

  static const maxFiles = 3;

  MainCubit() : super(MainState()) {
    _initialize();
  }

  void _initialize() async {
    final foodPreferences = await MainDataSource.getAllFoodPreferences();
    emit(state.copyWith(allPreferences: foodPreferences));
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
      final text = await MainDataSource.extractTextFromImage(photo);
      emit(state.copyWith(
        isFileLoading: false,
        menuImages: [...state.menuImages, (photo, text)],
      ));
    } catch (e) {
      _emitError('Error: $e');
      emit(state.copyWith(isFileLoading: false));
    }
  }

  void onSuggestMeClicked() async {
    if (state.apiKey.isEmpty) {
      _emitError('Please enter your API key');
      return;
    }

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
      final result = await MainDataSource.requestSuggestion(
        apiKey: state.apiKey,
        preferences: state.allPreferences,
        menuImages: state.menuImages.map((e) => e.$2).toList(),
        customPrompt: '',
      );

      emit(state.copyWith(
        response: result,
        isResponseLoading: false,
      ));
    } catch (e) {
      _emitError('Error: $e');
      emit(state.copyWith(isResponseLoading: false));
    }
  }
}
