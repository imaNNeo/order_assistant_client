import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyField extends StatefulWidget {
  ApiKeyField({
    super.key,
    required this.onApiKeyReady,
  });

  ValueChanged<String> onApiKeyReady;

  @override
  State<ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<ApiKeyField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // try to get the API key from shared preferences
    SharedPreferences.getInstance().then((prefs) {
      final apiKey = prefs.getString('apiKey');
      if (apiKey != null) {
        setState(() {
          _controller.text = apiKey;
        });
        widget.onApiKeyReady(apiKey);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'API Key',
        hintText: 'Enter your OpenAI API key',
      ),
      onChanged: (value) {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('apiKey', value);
        });
        widget.onApiKeyReady(value);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
