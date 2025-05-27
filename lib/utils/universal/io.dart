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

  // Return the 'location' header if there is a redirection
  return response.headers['location'];
}
