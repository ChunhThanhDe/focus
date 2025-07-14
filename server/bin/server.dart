import 'dart:convert';
import 'dart:io';

import 'package:server/unsplash.dart';
import 'package:shared/shared.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:unsplash_client/unsplash_client.dart' show Photo;

/// Get Unsplash API key from system environment variables
final String unsplashApiKey = Platform.environment['UNSPLASH_ACCESS_KEY'] ??
    String.fromEnvironment('UNSPLASH_ACCESS_KEY');

/// Define HTTP routes
final _router = Router()
  ..get('/', _rootHandler)
  ..get('/echo/<message>', _echoHandler)
  ..post('/unsplash/randomImage', _unsplashRandomImageHandler);

/// GET / → basic test route
Response _rootHandler(Request req) {
  return Response.ok('Hello, World!\n');
}

/// GET /echo/<message> → echoes the message
Response _echoHandler(Request request) {
  final message = request.params['message'];
  return Response.ok('$message\n');
}

/// POST /unsplash/randomImage → fetch a random Unsplash image based on source
Future<Response> _unsplashRandomImageHandler(Request request) async {
  try {
    final String payload = await request.readAsString();
    final Map<String, dynamic> sourceJson = jsonDecode(payload);

    final UnsplashSource source = UnsplashSource.fromJson(sourceJson['source']);
    final Photo? photo = await randomUnsplashImage(source: source);

    if (photo == null) {
      return Response.internalServerError(
          body: 'Could not get a photo from Unsplash.');
    }

    return Response.ok(
      jsonEncode(photo.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  } catch (error, stacktrace) {
    return Response.internalServerError(body: 'Error: $error\n$stacktrace\n');
  }
}

/// Main entry point to start the HTTP server
void main(List<String> args) async {
  if (env['UNSPLASH_ACCESS_KEY'] == null) {
    print('UNSPLASH_ACCESS_KEY is missing.');
    exit(1);
  }

  final ip = InternetAddress.anyIPv4;

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(enableCors())
      .addHandler(_router.call);

  final port = int.parse(Platform.environment['PORT'] ?? '8000');

  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}

/// Enables CORS for all origins (required for Flutter Web/Mobile HTTP requests)
Middleware enableCors() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers':
                'Origin, Content-Type, Authorization',
          },
        );
      }

      final response = await handler(request);
      return response.change(
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
        },
      );
    };
  };
}
