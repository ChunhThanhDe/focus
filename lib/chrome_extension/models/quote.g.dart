// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BuiltinQuote _$BuiltinQuoteFromJson(Map<String, dynamic> json) => BuiltinQuote(
  id: json['id'] as String,
  text: json['text'] as String,
  author: json['author'] as String,
  category: json['category'] as String?,
);

Map<String, dynamic> _$BuiltinQuoteToJson(BuiltinQuote instance) =>
    <String, dynamic>{
      'text': instance.text,
      'author': instance.author,
      'id': instance.id,
      'category': instance.category,
    };

CustomQuote _$CustomQuoteFromJson(Map<String, dynamic> json) => CustomQuote(
  id: json['id'] as String,
  text: json['text'] as String,
  author: json['author'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$CustomQuoteToJson(CustomQuote instance) =>
    <String, dynamic>{
      'text': instance.text,
      'author': instance.author,
      'id': instance.id,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
