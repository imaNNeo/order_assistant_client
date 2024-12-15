import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toastification/toastification.dart';

class HelperFunctions {
  static void showError(BuildContext context, String message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      title: Text('Something went wrong'),
      description: RichText(text: TextSpan(text: message)),
      alignment: Alignment.topRight,
    );
  }

  static Future<XFile?> loadOrTakePhoto() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }
}
