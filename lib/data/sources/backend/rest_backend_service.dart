/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';
import 'package:unsplash_client/unsplash_client.dart';

import 'backend_service.dart';

// Backup server URL (Cloud Run Asia region)
const String cloudRunUrl = 'https://focus-server-471257737108.asia-south1.run.app';

// Class implementing backend as RESTful API
class RestBackendService extends BackendService {
  String baseUrl = ''; // Variable to store the current server URL

  // ---------------------------------------------------------
  // Initialize backend: local server or production server
  @override
  Future<void> init({bool local = false}) async {
    if (local) {
      log('Initializing backend with local server');
      baseUrl = 'http://localhost:8000'; // use local server if available
    } else {
      log('Initializing backend with production server');
      baseUrl = cloudRunUrl; // otherwise use production server
    }
  }

  // ---------------------------------------------------------
  // Call backend server to get a random image from Unsplash
  @override
  Future<Photo?> randomUnsplashImage({
    required UnsplashSource source,
    required UnsplashPhotoOrientation orientation,
  }) async {
    // Send HTTP POST request to the backend API built in server/
    final result = await http.post(
      Uri.parse('$baseUrl/unsplash/randomImage'),
      headers: {'Content-Type': 'application/json'},
      // Request body includes source (collection/tags/random...) + orientation (landscape...)
      body: jsonEncode({
        'source': source.toJson(),
        'orientation': orientation.name,
      }),
    );

    // If the server returns 200 → parse the response into a Photo object
    if (result.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(result.body);
      return Photo.fromJson(json);
    }

    // If error → print error to console and throw exception
    log(result.body);
    throw HttpException(result.body);
  }
}
