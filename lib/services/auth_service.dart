import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'api_config.dart';
import '../models/player.dart';

/// Authentication service for Manus OAuth
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _api = ApiService();
  
  Player? _currentUser;
  PlayerProfile? _currentProfile;
  bool _isLoading = false;
  String? _error;
  
  Player? get currentUser => _currentUser;
  PlayerProfile? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;
  
  /// Check current authentication status
  Future<bool> checkAuth() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _api.query<Map<String, dynamic>>(
        'auth.me',
        fromJson: (data) => data as Map<String, dynamic>,
      );
      
      if (response.isSuccess && response.data != null) {
        _currentUser = Player.fromJson(response.data!);
        await _loadProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _currentUser = null;
        _currentProfile = null;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Failed to check authentication: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Load player profile
  Future<void> _loadProfile() async {
    final response = await _api.query<Map<String, dynamic>>(
      'profile.me',
      fromJson: (data) => data as Map<String, dynamic>,
    );
    
    if (response.isSuccess && response.data != null) {
      _currentProfile = PlayerProfile.fromJson(response.data!);
    }
  }
  
  /// Get login URL for OAuth
  String getLoginUrl() {
    return ApiConfig.oauthLogin;
  }
  
  /// Launch login in browser
  Future<bool> login() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final loginUrl = Uri.parse(getLoginUrl());
      
      if (await canLaunchUrl(loginUrl)) {
        final launched = await launchUrl(
          loginUrl,
          mode: LaunchMode.externalApplication,
        );
        
        _isLoading = false;
        notifyListeners();
        return launched;
      } else {
        _error = 'Could not launch login URL';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Set session from cookie obtained from WebView
  Future<void> setSessionFromCookie(String sessionCookie) async {
    await _api.setSessionCookie(sessionCookie);
  }
  
  /// Handle OAuth callback (called when app receives deep link)
  Future<bool> handleOAuthCallback(String callbackUrl) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // The callback URL contains the session info
      // After successful OAuth, check auth status
      final isAuthed = await checkAuth();
      return isAuthed;
    } catch (e) {
      _error = 'OAuth callback failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _api.mutation('auth.logout');
      await _api.clearSession();
      _currentUser = null;
      _currentProfile = null;
    } catch (e) {
      _error = 'Logout failed: $e';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  /// Update player profile
  Future<bool> updateProfile({
    String? displayName,
    String? avatarAsset,
  }) async {
    final response = await _api.mutation<Map<String, dynamic>>(
      'profile.update',
      input: {
        if (displayName != null) 'displayName': displayName,
        if (avatarAsset != null) 'avatarAsset': avatarAsset,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
    
    if (response.isSuccess && response.data != null) {
      _currentProfile = PlayerProfile.fromJson(response.data!);
      notifyListeners();
      return true;
    }
    
    _error = response.error;
    notifyListeners();
    return false;
  }
  
  /// Get player stats
  Future<PlayerStats?> getStats() async {
    final response = await _api.query<Map<String, dynamic>>(
      'profile.getStats',
      fromJson: (data) => data as Map<String, dynamic>,
    );
    
    if (response.isSuccess && response.data != null) {
      return PlayerStats.fromJson(response.data!);
    }
    return null;
  }
}

/// Player profile model
class PlayerProfile {
  final int id;
  final int userId;
  final String displayName;
  final String? avatarUrl;
  final String? avatarAsset;
  final int gamesPlayed;
  final int gamesWon;
  final int totalScore;
  final int? bestTime;
  final int raceWins;
  final int versusWins;
  final int coopWins;
  final int rankPoints;
  final int currentStreak;
  final int bestStreak;
  
  PlayerProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.avatarAsset,
    required this.gamesPlayed,
    required this.gamesWon,
    required this.totalScore,
    this.bestTime,
    required this.raceWins,
    required this.versusWins,
    required this.coopWins,
    required this.rankPoints,
    required this.currentStreak,
    required this.bestStreak,
  });
  
  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] as int,
      userId: json['userId'] as int,
      displayName: json['displayName'] as String? ?? 'Player',
      avatarUrl: json['avatarUrl'] as String?,
      avatarAsset: json['avatarAsset'] as String?,
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      totalScore: json['totalScore'] as int? ?? 0,
      bestTime: json['bestTime'] as int?,
      raceWins: json['raceWins'] as int? ?? 0,
      versusWins: json['versusWins'] as int? ?? 0,
      coopWins: json['coopWins'] as int? ?? 0,
      rankPoints: json['rankPoints'] as int? ?? 1000,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
    );
  }
  
  double get winRate => gamesPlayed > 0 ? (gamesWon / gamesPlayed) * 100 : 0;
}

/// Player stats model
class PlayerStats {
  final int gamesPlayed;
  final int gamesWon;
  final double winRate;
  final int totalScore;
  final int? bestTime;
  final int raceWins;
  final int versusWins;
  final int coopWins;
  final int rankPoints;
  final int currentStreak;
  final int bestStreak;
  
  PlayerStats({
    required this.gamesPlayed,
    required this.gamesWon,
    required this.winRate,
    required this.totalScore,
    this.bestTime,
    required this.raceWins,
    required this.versusWins,
    required this.coopWins,
    required this.rankPoints,
    required this.currentStreak,
    required this.bestStreak,
  });
  
  factory PlayerStats.fromJson(Map<String, dynamic> json) {
    return PlayerStats(
      gamesPlayed: json['gamesPlayed'] as int? ?? 0,
      gamesWon: json['gamesWon'] as int? ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0.0,
      totalScore: json['totalScore'] as int? ?? 0,
      bestTime: json['bestTime'] as int?,
      raceWins: json['raceWins'] as int? ?? 0,
      versusWins: json['versusWins'] as int? ?? 0,
      coopWins: json['coopWins'] as int? ?? 0,
      rankPoints: json['rankPoints'] as int? ?? 1000,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
    );
  }
}
