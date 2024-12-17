import 'package:equatable/equatable.dart';
import 'package:order_assistant/entity/suggestion_entity.dart';

class SuggestionResponse with EquatableMixin {
  final List<SuggestionEntity> suggestions;

  SuggestionResponse({
    required this.suggestions,
  });

  SuggestionResponse copyWith({
    List<SuggestionEntity>? suggestions,
  }) =>
      SuggestionResponse(
        suggestions: suggestions ?? this.suggestions,
      );

  factory SuggestionResponse.fromJson(Map<String, dynamic> json) =>
      SuggestionResponse(
        suggestions: (json['suggestions'] as List)
            .map((e) => SuggestionEntity.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'suggestions': suggestions.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object> get props => [
        suggestions,
      ];
}
