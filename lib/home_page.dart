import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:order_assistant/cubit/main_cubit.dart';

import 'api_key_field.dart';
import 'helper_functions.dart';
import 'loading_overlay.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String apiKey = '';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainState>(
      listener: (context, state) {
        if (state.error.isNotEmpty) {
          HelperFunctions.showError(context, state.error);
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
                  SizedBox(
                    width: 400,
                    child: ApiKeyField(
                      onApiKeyReady: (apiKey) {
                        setState(() {
                          this.apiKey = apiKey;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 18),
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
                          final (imageFile, imageText) = menuImages[index];
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
                                      image: NetworkImage(imageFile.path),
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
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Tooltip(
                                    message: 'View text',
                                    child: IconButton(
                                      icon: const Icon(Icons.remove_red_eye),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Extracted Text'),
                                              content: Text(imageText),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
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
                  SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    children: state.allPreferences
                        .map(
                          (preference) => Chip(
                            label: Text(preference),
                          ),
                        )
                        .toList(),
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
                    child: SingleChildScrollView(
                      child: Text(state.response),
                    ),
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
}
