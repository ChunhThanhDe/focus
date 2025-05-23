// This function is intended for use in server/cloud environments.

import 'package:dotenv/dotenv.dart';
import 'package:shared/shared.dart';
import 'package:unsplash_client/unsplash_client.dart';

final DotEnv env = DotEnv(includePlatformEnvironment: true)..load();

/// Fetches a random image from Unsplash based on the provided source type.
Future<Photo?> randomUnsplashImage({
  required UnsplashSource source,
  UnsplashPhotoOrientation? orientation = UnsplashPhotoOrientation.landscape,
}) async {
  final String? unsplashAccessKey = env['UNSPLASH_ACCESS_KEY'];
  if (unsplashAccessKey == null) {
    throw StateError('UNSPLASH_ACCESS_KEY is missing.');
  }

  final client = UnsplashClient(
    settings: ClientSettings(
      credentials: AppCredentials(accessKey: unsplashAccessKey),
    ),
  );

  switch (source) {
    case UnsplashCollectionSource source:
      final List<Photo> result = await client.photos.random(
        count: 1,
        orientation: PhotoOrientation.landscape,
        collections: [source.id],
      ).goAndGet();
      return result.firstOrNull;

    case UnsplashTagsSource source:
      final List<Photo> result = await client.photos
          .random(
            count: 1,
            orientation: PhotoOrientation.landscape,
            query: source.tags,
          )
          .goAndGet();
      return result.firstOrNull;

    case UnsplashRandomSource():
    case UnsplashUserLikesSource():
      final List<Photo> result = await client.photos
          .random(
            count: 1,
            orientation: PhotoOrientation.landscape,
          )
          .goAndGet();
      return result.firstOrNull;

    // Old version using username (not currently used)
    // case UnsplashUserLikesSource source:
    //   final List<Photo> result = await client.photos.random(
    //     count: 1,
    //     orientation: PhotoOrientation.landscape,
    //     username: source.id,
    //   ).goAndGet();
    //   return result.firstOrNull;
  }
}
