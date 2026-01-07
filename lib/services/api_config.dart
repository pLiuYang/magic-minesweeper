import 'dart:convert';

/// API Configuration for Magic Minesweeper Backend
class ApiConfig {
  // Backend URL - Update this when deploying to production
  static const String baseUrl = 'https://mms.manus.space';
  
  // Manus OAuth Portal URL
  static const String oauthPortalUrl = 'https://manus.im';
  
  // App ID from Manus - this should match your deployed app
  static const String appId = 'BEEgVzs3JognDxpcDyP6sP';
  
  // For local development
  // static const String baseUrl = 'http://localhost:3000';
  
  // tRPC API endpoints
  static const String trpcBase = '$baseUrl/api/trpc';
  
  // OAuth callback endpoint (on your backend)
  static const String oauthCallback = '$baseUrl/api/oauth/callback';
  
  // Generate OAuth login URL with proper parameters
  static String get oauthLogin {
    final redirectUri = oauthCallback;
    final state = base64Encode(utf8.encode(redirectUri));
    
    final uri = Uri.parse('$oauthPortalUrl/app-auth').replace(
      queryParameters: {
        'appId': appId,
        'redirectUri': redirectUri,
        'state': state,
        'type': 'signIn',
      },
    );
    
    return uri.toString();
  }
  
  // WebSocket path
  static const String socketPath = '/api/socket.io';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
