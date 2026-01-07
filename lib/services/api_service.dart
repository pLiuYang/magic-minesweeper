import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

/// API Service for communicating with the Magic Minesweeper backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final HttpClient _client = HttpClient();
  
  String? _sessionCookie;
  static const String _cookieKey = 'app_session_cookie';
  
  /// Get stored session cookie
  String? get sessionCookie => _sessionCookie;
  
  /// Initialize and load stored session cookie
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionCookie = prefs.getString(_cookieKey);
  }
  
  /// Set session cookie and persist it
  Future<void> setSessionCookie(String cookie) async {
    _sessionCookie = 'app_session_id=$cookie';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookieKey, _sessionCookie!);
  }
  
  /// Clear session cookie (logout)
  Future<void> clearSession() async {
    _sessionCookie = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
  }
  
  /// Make a tRPC query (GET request)
  Future<ApiResponse<T>> query<T>(
    String procedure, {
    Map<String, dynamic>? input,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      var uriString = '${ApiConfig.trpcBase}/$procedure';
      if (input != null) {
        final encoded = Uri.encodeComponent(jsonEncode({'json': input}));
        uriString += '?input=$encoded';
      }
      
      final uri = Uri.parse(uriString);
      final request = await _client.getUrl(uri);
      
      request.headers.set('Content-Type', 'application/json');
      if (_sessionCookie != null) {
        request.headers.set('Cookie', _sessionCookie!);
      }
      
      final response = await request.close().timeout(ApiConfig.connectionTimeout);
      final body = await response.transform(utf8.decoder).join();
      
      // Extract and store session cookie from response
      final cookies = response.cookies;
      if (cookies.isNotEmpty) {
        _sessionCookie = cookies.map((c) => '${c.name}=${c.value}').join('; ');
      }
      
      return _handleResponse(response.statusCode, body, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  /// Make a tRPC mutation (POST request)
  Future<ApiResponse<T>> mutation<T>(
    String procedure, {
    Map<String, dynamic>? input,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.trpcBase}/$procedure');
      final request = await _client.postUrl(uri);
      
      request.headers.set('Content-Type', 'application/json');
      if (_sessionCookie != null) {
        request.headers.set('Cookie', _sessionCookie!);
      }
      
      request.write(jsonEncode({'json': input ?? {}}));
      
      final response = await request.close().timeout(ApiConfig.connectionTimeout);
      final body = await response.transform(utf8.decoder).join();
      
      // Extract and store session cookie from response
      final cookies = response.cookies;
      if (cookies.isNotEmpty) {
        _sessionCookie = cookies.map((c) => '${c.name}=${c.value}').join('; ');
      }
      
      return _handleResponse(response.statusCode, body, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    int statusCode,
    String body,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final jsonBody = jsonDecode(body);
      
      if (statusCode >= 200 && statusCode < 300) {
        final result = jsonBody['result'];
        if (result != null && result['data'] != null) {
          final data = fromJson != null 
              ? fromJson(result['data']) 
              : result['data'] as T;
          return ApiResponse.success(data);
        }
        return ApiResponse.success(null as T);
      } else {
        final error = jsonBody['error'];
        final message = error?['message'] ?? 'Unknown error';
        return ApiResponse.error(message);
      }
    } catch (e) {
      return ApiResponse.error('Failed to parse response: $e');
    }
  }
}

/// Generic API response wrapper
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;
  
  ApiResponse._({this.data, this.error, required this.isSuccess});
  
  factory ApiResponse.success(T data) => ApiResponse._(
    data: data,
    isSuccess: true,
  );
  
  factory ApiResponse.error(String message) => ApiResponse._(
    error: message,
    isSuccess: false,
  );
}
