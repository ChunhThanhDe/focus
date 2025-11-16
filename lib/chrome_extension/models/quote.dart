import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'quote.g.dart';

/// Base quote interface
abstract class Quote extends Equatable {
  const Quote({
    required this.text,
    required this.author,
  });

  final String text;
  final String author;

  @override
  List<Object?> get props => [text, author];
}

/// Built-in quote from the extension's quote database
@JsonSerializable()
class BuiltinQuote extends Quote {
  const BuiltinQuote({
    required this.id,
    required super.text,
    required super.author,
    this.category,
  });

  final String id;
  final String? category;

  factory BuiltinQuote.fromJson(Map<String, dynamic> json) => _$BuiltinQuoteFromJson(json);
  Map<String, dynamic> toJson() => _$BuiltinQuoteToJson(this);

  @override
  List<Object?> get props => [id, text, author, category];
}

/// Custom quote created by the user
@JsonSerializable()
class CustomQuote extends Quote {
  const CustomQuote({
    required this.id,
    required super.text,
    required super.author,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CustomQuote.fromJson(Map<String, dynamic> json) => _$CustomQuoteFromJson(json);
  Map<String, dynamic> toJson() => _$CustomQuoteToJson(this);

  CustomQuote copyWith({
    String? id,
    String? text,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomQuote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, text, author, createdAt, updatedAt];
}

/// Quote source configuration
enum QuoteSource {
  builtin,
  custom,
  mixed;

  String get displayName {
    switch (this) {
      case QuoteSource.builtin:
        return 'Built-in Quotes';
      case QuoteSource.custom:
        return 'Custom Quotes';
      case QuoteSource.mixed:
        return 'Mixed (Built-in + Custom)';
    }
  }
}

/// Quote category for filtering
enum QuoteCategory {
  motivation,
  productivity,
  success,
  wisdom,
  inspiration,
  mindfulness,
  general;

  String get displayName {
    switch (this) {
      case QuoteCategory.motivation:
        return 'Motivation';
      case QuoteCategory.productivity:
        return 'Productivity';
      case QuoteCategory.success:
        return 'Success';
      case QuoteCategory.wisdom:
        return 'Wisdom';
      case QuoteCategory.inspiration:
        return 'Inspiration';
      case QuoteCategory.mindfulness:
        return 'Mindfulness';
      case QuoteCategory.general:
        return 'General';
    }
  }
}