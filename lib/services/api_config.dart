/// API Configuration for Magic Minesweeper Backend
class ApiConfig {
  // Backend URL - Update this when deploying to production
  static const String baseUrl = 'https://mms.manus.space';
  
  // For local development
  // static const String baseUrl = 'http://localhost:3000';
  
  // tRPC API endpoints
  static const String trpcBase = '$baseUrl/api/trpc';
  
  // OAuth endpoints
  static const String oauthLogin = '$baseUrl/api/oauth/login';
  static const String oauthCallback = '$baseUrl/api/oauth/callback';
  
  // WebSocket path
  static const String socketPath = '/api/socket.io';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
