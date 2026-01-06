import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_config.dart';

/// API Service for communicating with the Magic Minesweeper backend
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  String? _sessionCookie;
  
  /// Get stored session cookie
  Future<String?> get sessionCookie async {
    _sessionCookie ??= await _storage.read(key: 'session_cookie');
    return _sessionCookie;
  }
  
  /// Set session cookie
  Future<void> setSessionCookie(String cookie) async {
    _sessionCookie = cookie;
    await _storage.write(key: 'session_cookie', value: cookie);
  }
  
  /// Clear session cookie (logout)
  Future<void> clearSession() async {
    _sessionCookie = null;
    await _storage.delete(key: 'session_cookie');
  }
  
  /// Build headers with authentication
  Future<Map<String, String>> _buildHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    
    final cookie = await sessionCookie;
    if (cookie != null) {
      headers['Cookie'] = cookie;
    }
    
    return headers;
  }
  
  /// Make a tRPC query (GET request)
  Future<ApiResponse<T>> query<T>(
    String procedure, {
    Map<String, dynamic>? input,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.trpcBase}/$procedure');
      final queryParams = input != null
          ? {'input': jsonEncode({'json': input})}
          : null;
      
      final response = await _client.get(
        queryParams != null ? uri.replace(queryParameters: queryParams) : uri,
        headers: await _buildHeaders(),
      ).timeout(ApiConfig.connectionTimeout);
      
      return _handleResponse(response, fromJson);
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
      final response = await _client.post(
        Uri.parse('${ApiConfig.trpcBase}/$procedure'),
        headers: await _buildHeaders(),
        body: jsonEncode({'json': input ?? {}}),
      ).timeout(ApiConfig.connectionTimeout);
      
      // Extract and store session cookie from response
      final setCookie = response.headers['set-cookie'];
      if (setCookie != null) {
        await setSessionCookie(setCookie);
      }
      
      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }
  
  /// Handle HTTP response
  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJson,
  ) {
    try {
      final body = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final result = body['result'];
        if (result != null && result['data'] != null) {
          final data = fromJson != null 
              ? fromJson(result['data']) 
              : result['data'] as T;
          return ApiResponse.success(data);
        }
        return ApiResponse.success(null as T);
      } else {
        final error = body['error'];
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
