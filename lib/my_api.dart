import 'package:dart_openai/dart_openai.dart';

class MyApi {
  static Future<String> requestSuggestion({
    required String apiKey,
    required List<String> preferences,
    required List<String> menuImages,
    required String? customPrompt,
  }) async {
    // Define the system prompt
    const String systemPrompt = """
You are a smart and helpful AI assistant for food recommendations. Analyze menu items and suggest dishes based on the user's dietary preferences, allergies, and instructions.

Rules:
1. Ask about preferences or allergies if unclear.
2. Recommend dishes that align with user preferences.
3. Exclude dishes with ingredients the user is allergic to.
4. Suggest up to 3 dishes with a brief explanation.
5. Follow custom instructions.
6. Respond in JSON format:
{
    "suggestions": [
        {"name": "Dish name", "imageUrl": "URL (optional)"}
    ],
    "newDetectedPreferences": ["New preference or allergy detected"]
}
""";

    OpenAI.apiKey = apiKey;
    // User input
    final userInputText = """
Preferences:
${preferences.join(", ")}

${customPrompt != null && customPrompt.trim().isNotEmpty ? """
Custom prompt:
I want something light to eat before I sleep. It's late at night and I don't want to eat rice at night.
""" : ''}
""";

    // Create OpenAI chat completion request
    final response = await OpenAI.instance.chat.create(
      model: "gpt-4",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.system,
            content: [
              OpenAIChatCompletionChoiceMessageContentItemModel.text(
                systemPrompt,
              ),
            ]),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              userInputText,
            ),
          ],
        ),
        OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              'Extracted menu text:\n${menuImages.join('\n')}',
            ),
          ],
        ),
      ],
      temperature: 0.5,
      maxTokens: 2048,
      topP: 1,
      frequencyPenalty: 0,
      presencePenalty: 0,
    );

    // Print the JSON response
    return response.choices.first.message.content!.first.text!;
  }
}
