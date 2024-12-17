import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_assistant/cubit/main_cubit.dart';

import 'helper_functions.dart';
import 'loading_overlay.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String apiKey = '';

  late MainCubit mainCubit;

  @override
  void didChangeDependencies() {
    mainCubit = context.read<MainCubit>();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainState>(
      listener: (context, state) {
        if (state.error.isNotEmpty) {
          HelperFunctions.showError(context, state.error);
        }

        if (state.response != null) {
          // show a dialog with the response
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Suggestions'),
                content: SelectionArea(
                  child: SizedBox(
                    width: 600,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: state.response!.suggestions.map((suggestion) {
                        return ListTile(
                          title: Text(suggestion.name),
                          subtitle: Text(suggestion.explanation),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Smart Order Assistant'),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(flex: 1, child: Container()),
                  Row(
                    spacing: 12,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(
                          min(
                            state.menuImages.length + 1,
                            MainCubit.maxFiles,
                          ), (index) {
                        final menuImages = state.menuImages;
                        if (index < menuImages.length) {
                          final image = menuImages[index];
                          return SizedBox(
                            width: 100,
                            height: 100,
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black38),
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(image.file.path),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Tooltip(
                                    message: 'Remove this menu image',
                                    child: IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          menuImages.removeAt(index);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        if (menuImages.length >= MainCubit.maxFiles) {
                          return const SizedBox.shrink();
                        }
                        return InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: state.isFileLoading
                              ? null
                              : context.read<MainCubit>().addNewImage,
                          child: Tooltip(
                            message: 'Add a menu image',
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black38),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: state.isFileLoading
                                    ? CircularProgressIndicator()
                                    : Icon(Icons.add),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  SizedBox(height: 32),
                  Text('Food Preferences:'),
                  SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    children: [
                      ActionChip(
                        onPressed: () => _onAddNewClicked(context),
                        label: Text(
                          '+ Add New',
                          style: TextStyle(
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      ...state.allPreferences.map(
                        (preference) => Chip(
                          label: Text(
                            preference,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onDeleted: () => mainCubit.removeFoodPreference(
                            preference,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  SizedBox(
                    width: 400,
                    child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Custom prompt (optional)',
                        ),
                        maxLines: 3,
                        onChanged: (value) {}),
                  ),
                  Expanded(flex: 1, child: Container()),
                  ElevatedButton(
                    onPressed: state.isResponseLoading || state.isFileLoading
                        ? null
                        : () => _suggestMe(context),
                    child: const Text('Suggest Me!'),
                  ),
                  Expanded(
                    flex: 2,
                    child:Container(),
                  ),
                ],
              ),
              if (state.isResponseLoading) const LoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  void _suggestMe(BuildContext context) async {
    context.read<MainCubit>().onSuggestMeClicked();
  }

  Future<String?> _showPopupAndGetText(BuildContext context) async {
    final textController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Preference'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter your preference',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, textController.text);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    textController.dispose();
    return result;
  }

  void _onAddNewClicked(BuildContext context) async {
    final newEnteredText = await _showPopupAndGetText(context);
    if (newEnteredText != null && newEnteredText.trim().isNotEmpty) {
      mainCubit.addFoodPreference(newEnteredText);
    }
  }
}
