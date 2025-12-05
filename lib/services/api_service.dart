import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.31.41:5000/";
  static Map<String, String> _headers({String? token}) {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  /// GET Request
  static Future<dynamic> get(String endpoint, {String? token}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.get(url, headers: _headers(token: token));

    return _processResponse(response);
  }

  /// POST Request
  static Future<dynamic> post(String endpoint, Map data, {String? token}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    print(url);
    final response = await http.post(
      url,
      headers: _headers(token: token),
      body: jsonEncode(data),
    );

    return _processResponse(response);
  }

  /// PUT Request
  static Future<dynamic> put(String endpoint, Map data, {String? token}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.put(
      url,
      headers: _headers(token: token),
      body: jsonEncode(data),
    );

    return _processResponse(response);
  }

  /// DELETE Request
  static Future<dynamic> delete(String endpoint, {String? token}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await http.delete(
      url,
      headers: _headers(token: token),
    );

    return _processResponse(response);
  }

  /// Response Handler
  static dynamic _processResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 400:
        //throw Exception("Bad Request: $body");
        return body;
      case 401:
        //throw Exception("Unauthorized: Token may be invalid/expired");
        return body;
      case 404:
        throw Exception("Not Found: Endpoint is wrong");
      case 500:
        throw Exception("Server Error: Try again later");
      default:
        throw Exception("Error ${response.statusCode}: $body");
    }
  }
}
