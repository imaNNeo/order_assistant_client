import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<(XFile, String)> menuImages = [];
  static const _maxFiles = 3;

  bool isFileLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Order Assistant'),
      ),
      body: Center(
        child: Column(
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
                            final photo = await _loadOrTakePhoto(context);
                            if (photo == null) {
                              return;
                            }
                            final text = await _extractTextFromImage(photo);
                            setState(() {
                              menuImages.add((photo, text));
                              isFileLoading = false;
                            });
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
            Expanded(flex: 1, child: Container()),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Suggest Me!'),
            ),
            Expanded(flex: 2, child: Container()),
          ],
        ),
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
}
