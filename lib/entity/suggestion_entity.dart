import 'package:equatable/equatable.dart';

class SuggestionEntity with EquatableMixin {
  final String name;
  final String explanation;

  SuggestionEntity({
    required this.name,
    required this.explanation,
  });

  SuggestionEntity copyWith({
    String? name,
    String? explanation,
  }) =>
      SuggestionEntity(
        name: name ?? this.name,
        explanation: explanation ?? this.explanation,
      );

  factory SuggestionEntity.fromJson(Map<String, dynamic> json) =>
      SuggestionEntity(
        name: json['name'] as String,
        explanation: json['explanation'] as String,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'explanation': explanation,
      };

  @override
  List<Object> get props => [
        name,
        explanation,
      ];
}
