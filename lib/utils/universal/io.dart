/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-11-12 11:01:44
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Saves a list of bytes as an image file to the specified path
Future<void> downloadImage(Uint8List bytes, String path) => File(path).writeAsBytes(bytes);

/// Sends a GET request to the given URL and returns the URL to which it redirects (if any)
Future<String?> getRedirectionUrl(String url) async {
  final client = http.Client();
  var uri = Uri.parse(url);

  // Prepare a GET request without following redirects
  var request = http.Request('get', uri);
  request.followRedirects = false;

  // Send the request and receive the response
  var response = await client.send(request);

  // Check if the response status code is a redirection (3xx)
  if (response.statusCode >= 300 && response.statusCode < 400) {
    // Return the 'location' header if there is a redirection
    return response.headers['location'];
  }

  // If not a redirection, return null
  return null;
}
