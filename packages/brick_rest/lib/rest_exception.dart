import 'package:http/http.dart' as http;
import 'dart:convert';

/// An error class exclusive to the [RestProvider]
class RestException implements Exception {
  final http.Response response;

  RestException(this.response);

  /// Decoded error messages if included under the top-level key "errors" in the response.
  /// For example, ```{"phone": ["Phone required"]}``` in ```{"errors":{"phone": ["Phone required"]}}```.
  Map<String, dynamic> get errors {
    if (response.body != null) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey("errors")) {
          return decoded["errors"];
        }
      } catch (e) {}
    }

    return null;
  }

  String get message =>
      "statusCode=${response?.statusCode} url=${response?.request?.url} method=${response?.request?.method} body=${response?.body}";

  toString() => message;
}
