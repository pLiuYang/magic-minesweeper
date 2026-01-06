import 'dart:async';
import 'api_service.dart';

/// Service for matchmaking queue management
class MatchmakingService {
  static final MatchmakingService _instance = MatchmakingService._internal();
  factory MatchmakingService() => _instance;
  MatchmakingService._internal();

  final ApiService _api = ApiService();
  
  Timer? _pollTimer;
  bool _isSearching = false;
  
  bool get isSearching => _isSearching;

  /// Join matchmaking queue
  Future<MatchmakingResult> joinQueue({
    required String mode,
    required String difficulty,
  }) async {
    final response = await _api.mutation<Map<String, dynamic>>(
      'matchmaking.join',
      input: {
        'mode': mode,
        'difficulty': difficulty,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      _isSearching = true;
      return MatchmakingResult.fromJson(response.data!);
    }

    return MatchmakingResult(
      status: MatchmakingStatus.error,
      error: response.error,
    );
  }

  /// Check matchmaking status
  Future<MatchmakingResult> checkStatus() async {
    final response = await _api.query<Map<String, dynamic>>(
      'matchmaking.status',
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response.isSuccess && response.data != null) {
      final result = MatchmakingResult.fromJson(response.data!);
      if (result.status != MatchmakingStatus.searching) {
        _isSearching = false;
      }
      return result;
    }

    return MatchmakingResult(
      status: MatchmakingStatus.notInQueue,
    );
  }

  /// Leave matchmaking queue
  Future<bool> leaveQueue() async {
    _stopPolling();
    _isSearching = false;
    
    final response = await _api.mutation<bool>(
      'matchmaking.leave',
      fromJson: (data) => data as bool,
    );

    return response.isSuccess;
  }

  /// Start polling for match status
  void startPolling({
    required Function(MatchmakingResult) onStatusUpdate,
    Duration interval = const Duration(seconds: 2),
  }) {
    _stopPolling();
    
    _pollTimer = Timer.periodic(interval, (_) async {
      final result = await checkStatus();
      onStatusUpdate(result);
      
      if (result.status == MatchmakingStatus.matched ||
          result.status == MatchmakingStatus.error ||
          result.status == MatchmakingStatus.notInQueue) {
        _stopPolling();
      }
    });
  }

  /// Stop polling
  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Dispose resources
  void dispose() {
    _stopPolling();
  }
}

/// Matchmaking status enum
enum MatchmakingStatus {
  notInQueue,
  searching,
  matched,
  error,
}

/// Matchmaking result
class MatchmakingResult {
  final MatchmakingStatus status;
  final int? matchId;
  final String? error;
  final int? queuePosition;
  final Duration? estimatedWait;

  MatchmakingResult({
    required this.status,
    this.matchId,
    this.error,
    this.queuePosition,
    this.estimatedWait,
  });

  factory MatchmakingResult.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String?;
    MatchmakingStatus status;
    
    switch (statusStr) {
      case 'searching':
        status = MatchmakingStatus.searching;
        break;
      case 'matched':
        status = MatchmakingStatus.matched;
        break;
      case 'error':
        status = MatchmakingStatus.error;
        break;
      default:
        status = MatchmakingStatus.notInQueue;
    }

    return MatchmakingResult(
      status: status,
      matchId: json['matchId'] as int?,
      error: json['error'] as String?,
      queuePosition: json['queuePosition'] as int?,
      estimatedWait: json['estimatedWait'] != null
          ? Duration(seconds: json['estimatedWait'] as int)
          : null,
    );
  }
}
