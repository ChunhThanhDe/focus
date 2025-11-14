/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:shared/shared.dart';
import 'package:unsplash_client/unsplash_client.dart';

// Define an abstract class (interface) for the backend
abstract class BackendService {
  // Initialize the backend (choose local or production server)
  Future<void> init({bool local = false});

  // Function to call the backend to get an image from Unsplash
  Future<Photo?> randomUnsplashImage({
    required UnsplashSource source, // image source (collection, tags, random, etc.)
    required UnsplashPhotoOrientation orientation, // desired image orientation
  });
}
