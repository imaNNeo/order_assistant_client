import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_assistant/helper_functions.dart';
import 'package:order_assistant/my_api.dart';

import 'api_key_field.dart';
import 'loading_overlay.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<(XFile, String)> menuImages = [];
  static const _maxFiles = 3;

  bool isFileLoading = false;
  bool isResponseLoading = false;
  String response = '';
  String apiKey = '';

  @override
  Widget build(BuildContext context) {
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
                  ...List.generate(min(menuImages.length + 1, _maxFiles),
                      (index) {
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
                                          title: const Text('Extracted Text'),
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

                    if (menuImages.length >= _maxFiles) {
                      return const SizedBox.shrink();
                    }
                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: isFileLoading
                          ? null
                          : () async {
                              setState(() {
                                isFileLoading = true;
                              });
                              try {
                                final photo = await _loadOrTakePhoto(context);
                                if (photo == null) {
                                  setState(() {
                                    isFileLoading = false;
                                  });
                                  return;
                                }
                                final text = await _extractTextFromImage(photo);
                                setState(() {
                                  menuImages.add((photo, text));
                                  isFileLoading = false;
                                });
                              } catch (e) {
                                setState(() {
                                  isFileLoading = false;
                                });
                                if (context.mounted) {
                                  HelperFunctions.showError(
                                      context, e.toString());
                                }
                              }
                            },
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
                            child: isFileLoading
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
                onPressed: isResponseLoading || isFileLoading
                    ? null
                    : () => _suggestMe(context),
                child: const Text('Suggest Me!'),
              ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(
                  child: Text(response),
                ),
              ),
            ],
          ),
          if (isResponseLoading) const LoadingOverlay(),
        ],
      ),
    );
  }

  Future<XFile?> _loadOrTakePhoto(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  Future<String> _extractTextFromImage(XFile imageFile) async {
    return await FlutterTesseractOcr.extractText(
      imageFile.path,
      language: 'fas+eng+nld+fra+deu+ita',
      args: {
        "psm": "4",
        "preserve_interword_spaces": "1",
      },
    );
  }

  void _suggestMe(BuildContext context) async {
    if (apiKey.isEmpty) {
      HelperFunctions.showError(context, 'Please enter your API key');
      return;
    }

    if (menuImages.isEmpty) {
      HelperFunctions.showError(context, 'Please add at least one menu image');
      return;
    }

    if (isResponseLoading) {
      return;
    }

    if (isFileLoading) {
      return;
    }

    setState(() {
      isResponseLoading = true;
    });
    try {
      final result = await MyApi.requestSuggestion(
        apiKey: apiKey,
        preferences: [
          'Avoid ginger',
          'No pork',
          'Likes potato',
          'broccoli',
          'and cabbage',
          'Prefers light meals before sleep',
        ],
        menuImages: menuImages.map((e) => e.$2).toList(),
        customPrompt: '',
      );

      setState(() {
        response = result;
        isResponseLoading = false;
      });
    } catch (e) {
      setState(() {
        response = 'Error: $e';
        isResponseLoading = false;
      });
      if (context.mounted) {
        HelperFunctions.showError(context, e.toString());
      }
    }
  }
}
