/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'unsplash_collection.g.dart';

/// Types of image sources from Unsplash
enum UnsplashSourceType {
  random,
  collection,
  likes,
  tags,
}

/// Orientation types for photos
enum UnsplashPhotoOrientation {
  landscape,
  portrait,
  squarish;

  static UnsplashPhotoOrientation fromAspectRatio(double aspectRatio) => aspectRatio > 1.0
      ? UnsplashPhotoOrientation.landscape
      : aspectRatio < 1.0
          ? UnsplashPhotoOrientation.portrait
          : UnsplashPhotoOrientation.squarish;
}

/// Base class for Unsplash image sources
sealed class UnsplashSource with EquatableMixin {
  final String name;
  abstract final UnsplashSourceType type;

  const UnsplashSource({required this.name});

  String getPath();
  Map<String, dynamic> toJson();

  factory UnsplashSource.fromJson(Map<String, dynamic> json) {
    final type = json['type'] != null ? UnsplashSourceType.values.byName(json['type']) : UnsplashSourceType.random;

    switch (type) {
      case UnsplashSourceType.random:
        return UnsplashRandomSource.fromJson(json);
      case UnsplashSourceType.collection:
        return UnsplashCollectionSource.fromJson(json);
      case UnsplashSourceType.likes:
        return UnsplashUserLikesSource.fromJson(json);
      case UnsplashSourceType.tags:
        return UnsplashTagsSource.fromJson(json);
    }
  }
}

@JsonSerializable()
class UnsplashRandomSource extends UnsplashSource {
  @override
  final UnsplashSourceType type = UnsplashSourceType.random;

  const UnsplashRandomSource({super.name = 'Random'});

  @override
  String getPath() => '/random';

  factory UnsplashRandomSource.fromJson(Map<String, dynamic> json) => _$UnsplashRandomSourceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UnsplashRandomSourceToJson(this)..['type'] = type.name;

  @override
  List<Object?> get props => [type, name];
}

/// Base class for sources that require an ID (e.g., user or collection)
sealed class UnsplashIdentifiableSource extends UnsplashSource {
  final String id;

  const UnsplashIdentifiableSource({
    required this.id,
    required super.name,
  });
}

@JsonSerializable()
class UnsplashCollectionSource extends UnsplashIdentifiableSource {
  @override
  final UnsplashSourceType type = UnsplashSourceType.collection;

  const UnsplashCollectionSource({
    required super.id,
    required super.name,
  });

  @override
  String getPath() => '/collection/$id';

  factory UnsplashCollectionSource.fromJson(Map<String, dynamic> json) => _$UnsplashCollectionSourceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UnsplashCollectionSourceToJson(this)..['type'] = type.name;

  @override
  List<Object?> get props => [type, id, name];
}

@JsonSerializable()
class UnsplashUserLikesSource extends UnsplashIdentifiableSource {
  @override
  final UnsplashSourceType type = UnsplashSourceType.likes;

  const UnsplashUserLikesSource({
    required super.id,
    required super.name,
  });

  @override
  String getPath() => '/user/$id/likes';

  factory UnsplashUserLikesSource.fromJson(Map<String, dynamic> json) => _$UnsplashUserLikesSourceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UnsplashUserLikesSourceToJson(this)..['type'] = type.name;

  @override
  List<Object?> get props => [type, id, name];
}

@JsonSerializable()
class UnsplashTagsSource extends UnsplashRandomSource {
  final String tags;

  const UnsplashTagsSource({required this.tags}) : super(name: '');

  @override
  String get name => tags;

  String get suffix => '/?/$tags';

  @override
  UnsplashSourceType get type => UnsplashSourceType.tags;

  factory UnsplashTagsSource.fromJson(Map<String, dynamic> json) => _$UnsplashTagsSourceFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UnsplashTagsSourceToJson(this)..['type'] = type.name;

  @override
  List<Object?> get props => [type, suffix];
}
