import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<XFile> menuImages = [];

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
              mainAxisSize: MainAxisSize.min,
              children: [
                ...List.generate(menuImages.length + 1, (index) {
                  if (index < menuImages.length) {
                    // render image
                    return Tooltip(
                      message: 'Remove this menu image',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black38),
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: NetworkImage(menuImages[index].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }
                  return InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      final photo = await _loadOrTakePhoto(context);
                      if (photo != null) {
                        setState(() {
                          menuImages.add(photo);
                        });
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
                        child: const Center(
                          child: Icon(Icons.add),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
    // show context menu
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        );
      },
    );

    if (source == null) {
      return null;
    };

    final ImagePicker picker = ImagePicker();
    XFile? image;
    switch (source) {
      case ImageSource.camera:
        image = await picker.pickImage(source: ImageSource.camera);
        break;
      case ImageSource.gallery:
        image = await picker.pickImage(source: ImageSource.gallery);
        break;
    }

    return image;
  }
}
