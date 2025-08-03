import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  final Map<String, String> _defaultHeaders;

  ApiClient({
    required this.baseUrl,
    Map<String, String>? defaultHeaders,
  }) : _defaultHeaders = defaultHeaders ??
            {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            };

  Map<String, String> get headers => _defaultHeaders;

  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = {..._defaultHeaders, ...?headers};

    return await http.get(uri, headers: mergedHeaders);
  }

  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = {..._defaultHeaders, ...?headers};

    return await http.post(
      uri,
      headers: mergedHeaders,
      body: body,
    );
  }

  Future<http.Response> put(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = {..._defaultHeaders, ...?headers};

    return await http.put(
      uri,
      headers: mergedHeaders,
      body: body,
    );
  }

  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = {..._defaultHeaders, ...?headers};

    return await http.delete(uri, headers: mergedHeaders);
  }

  void setAuthToken(String token) {
    _defaultHeaders['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _defaultHeaders.remove('Authorization');
  }
}
