import 'package:flutter/cupertino.dart';
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
}
