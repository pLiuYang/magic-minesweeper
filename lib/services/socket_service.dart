import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'api_config.dart';

/// WebSocket service for real-time multiplayer communication
class SocketService extends ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  WebSocket? _socket;
  bool _isConnected = false;
  int? _currentMatchId;
  int? _currentUserId;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  bool get isConnected => _isConnected;
  int? get currentMatchId => _currentMatchId;

  // Event streams
  final _gameStateController = StreamController<GameStateEvent>.broadcast();
  final _playerJoinedController = StreamController<PlayerJoinedEvent>.broadcast();
  final _playerReadyController = StreamController<PlayerReadyEvent>.broadcast();
  final _gameStartingController = StreamController<GameStartingEvent>.broadcast();
  final _gameStartedController = StreamController<GameStartedEvent>.broadcast();
  final _actionPerformedController = StreamController<ActionPerformedEvent>.broadcast();
  final _progressUpdatedController = StreamController<ProgressUpdatedEvent>.broadcast();
  final _spellCastController = StreamController<SpellCastEvent>.broadcast();
  final _playerFinishedController = StreamController<PlayerFinishedEvent>.broadcast();
  final _gameOverController = StreamController<GameOverEvent>.broadcast();
  final _playerDisconnectedController = StreamController<PlayerDisconnectedEvent>.broadcast();
  final _playerReconnectedController = StreamController<PlayerReconnectedEvent>.broadcast();
  final _chatMessageController = StreamController<ChatMessageEvent>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Event streams getters
  Stream<GameStateEvent> get onGameState => _gameStateController.stream;
  Stream<PlayerJoinedEvent> get onPlayerJoined => _playerJoinedController.stream;
  Stream<PlayerReadyEvent> get onPlayerReady => _playerReadyController.stream;
  Stream<GameStartingEvent> get onGameStarting => _gameStartingController.stream;
  Stream<GameStartedEvent> get onGameStarted => _gameStartedController.stream;
  Stream<ActionPerformedEvent> get onActionPerformed => _actionPerformedController.stream;
  Stream<ProgressUpdatedEvent> get onProgressUpdated => _progressUpdatedController.stream;
  Stream<SpellCastEvent> get onSpellCast => _spellCastController.stream;
  Stream<PlayerFinishedEvent> get onPlayerFinished => _playerFinishedController.stream;
  Stream<GameOverEvent> get onGameOver => _gameOverController.stream;
  Stream<PlayerDisconnectedEvent> get onPlayerDisconnected => _playerDisconnectedController.stream;
  Stream<PlayerReconnectedEvent> get onPlayerReconnected => _playerReconnectedController.stream;
  Stream<ChatMessageEvent> get onChatMessage => _chatMessageController.stream;
  Stream<String> get onError => _errorController.stream;

  /// Connect to the WebSocket server
  Future<bool> connect() async {
    if (_isConnected) return true;

    try {
      final wsUrl = ApiConfig.baseUrl.replaceFirst('http', 'ws') + ApiConfig.socketPath;
      _socket = await WebSocket.connect(wsUrl).timeout(
        const Duration(seconds: 10),
      );

      _isConnected = true;
      _reconnectAttempts = 0;
      notifyListeners();

      _setupEventListeners();
      _startHeartbeat();

      return true;
    } catch (e) {
      debugPrint('Socket connection error: $e');
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  /// Setup event listeners
  void _setupEventListeners() {
    _socket?.listen(
      (data) {
        try {
          final message = jsonDecode(data as String) as Map<String, dynamic>;
          final event = message['event'] as String?;
          final payload = message['data'] as Map<String, dynamic>?;

          if (event == null || payload == null) return;

          switch (event) {
            case 'game_state':
              _gameStateController.add(GameStateEvent.fromJson(payload));
              break;
            case 'player_joined':
              _playerJoinedController.add(PlayerJoinedEvent.fromJson(payload));
              break;
            case 'player_ready_changed':
              _playerReadyController.add(PlayerReadyEvent.fromJson(payload));
              break;
            case 'game_starting':
              _gameStartingController.add(GameStartingEvent.fromJson(payload));
              break;
            case 'game_started':
              _gameStartedController.add(GameStartedEvent.fromJson(payload));
              break;
            case 'action_performed':
              _actionPerformedController.add(ActionPerformedEvent.fromJson(payload));
              break;
            case 'progress_updated':
              _progressUpdatedController.add(ProgressUpdatedEvent.fromJson(payload));
              break;
            case 'spell_cast':
              _spellCastController.add(SpellCastEvent.fromJson(payload));
              break;
            case 'player_finished':
              _playerFinishedController.add(PlayerFinishedEvent.fromJson(payload));
              break;
            case 'game_over':
              _gameOverController.add(GameOverEvent.fromJson(payload));
              break;
            case 'player_disconnected':
              _playerDisconnectedController.add(PlayerDisconnectedEvent.fromJson(payload));
              break;
            case 'player_reconnected':
              _playerReconnectedController.add(PlayerReconnectedEvent.fromJson(payload));
              break;
            case 'chat_message':
              _chatMessageController.add(ChatMessageEvent.fromJson(payload));
              break;
            case 'error':
              _errorController.add(payload['message'] as String? ?? 'Unknown error');
              break;
          }
        } catch (e) {
          debugPrint('Error parsing socket message: $e');
        }
      },
      onDone: () {
        _isConnected = false;
        notifyListeners();
        _attemptReconnect();
      },
      onError: (error) {
        debugPrint('Socket error: $error');
        _isConnected = false;
        notifyListeners();
        _attemptReconnect();
      },
    );
  }

  /// Start heartbeat to keep connection alive
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_isConnected) {
        _emit('ping', {});
      }
    });
  }

  /// Attempt to reconnect
  void _attemptReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: 1 << _reconnectAttempts), () async {
      _reconnectAttempts++;
      final success = await connect();
      if (success && _currentMatchId != null && _currentUserId != null) {
        reconnectGame(_currentMatchId!, _currentUserId!);
      }
    });
  }

  /// Emit an event
  void _emit(String event, Map<String, dynamic> data) {
    if (_socket != null && _isConnected) {
      _socket!.add(jsonEncode({'event': event, 'data': data}));
    }
  }

  /// Join a game
  void joinGame(int matchId, int userId) {
    _currentMatchId = matchId;
    _currentUserId = userId;
    _emit('join_game', {
      'matchId': matchId,
      'userId': userId,
    });
  }

  /// Set player ready status
  void setReady(int matchId, bool ready) {
    _emit('player_ready', {
      'matchId': matchId,
      'ready': ready,
    });
  }

  /// Perform a player action
  void performAction({
    required int matchId,
    required int userId,
    required String action,
    required int row,
    required int col,
    String? spellType,
    int? targetUserId,
  }) {
    _emit('player_action', {
      'matchId': matchId,
      'userId': userId,
      'action': action,
      'row': row,
      'col': col,
      if (spellType != null) 'spellType': spellType,
      if (targetUserId != null) 'targetUserId': targetUserId,
    });
  }

  /// Update progress
  void updateProgress({
    required int matchId,
    required int score,
    required int tilesRevealed,
    required int mana,
  }) {
    _emit('update_progress', {
      'matchId': matchId,
      'score': score,
      'tilesRevealed': tilesRevealed,
      'mana': mana,
    });
  }

  /// Cast a spell
  void castSpell({
    required int matchId,
    required int casterId,
    required int targetId,
    required String spellType,
    required int duration,
  }) {
    _emit('cast_spell', {
      'matchId': matchId,
      'casterId': casterId,
      'targetId': targetId,
      'spellType': spellType,
      'duration': duration,
    });
  }

  /// Report player finished
  void playerFinished({
    required int matchId,
    required bool won,
    required bool hitMine,
    required int score,
    required int completionTime,
    required int tilesRevealed,
    required int flagsPlaced,
    required int manaUsed,
    required int spellsCast,
  }) {
    _emit('player_finished', {
      'matchId': matchId,
      'won': won,
      'hitMine': hitMine,
      'score': score,
      'completionTime': completionTime,
      'tilesRevealed': tilesRevealed,
      'flagsPlaced': flagsPlaced,
      'manaUsed': manaUsed,
      'spellsCast': spellsCast,
    });
  }

  /// Reconnect to a game
  void reconnectGame(int matchId, int userId) {
    _emit('reconnect_game', {
      'matchId': matchId,
      'userId': userId,
    });
  }

  /// Send a chat message
  void sendChatMessage(int matchId, String message) {
    _emit('chat_message', {
      'matchId': matchId,
      'message': message,
    });
  }

  /// Leave current game
  void leaveGame() {
    _currentMatchId = null;
    _currentUserId = null;
  }

  /// Disconnect from the server
  void disconnect() {
    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _socket?.close();
    _socket = null;
    _isConnected = false;
    _currentMatchId = null;
    _currentUserId = null;
    notifyListeners();
  }

  /// Dispose resources
  @override
  void dispose() {
    disconnect();
    _gameStateController.close();
    _playerJoinedController.close();
    _playerReadyController.close();
    _gameStartingController.close();
    _gameStartedController.close();
    _actionPerformedController.close();
    _progressUpdatedController.close();
    _spellCastController.close();
    _playerFinishedController.close();
    _gameOverController.close();
    _playerDisconnectedController.close();
    _playerReconnectedController.close();
    _chatMessageController.close();
    _errorController.close();
    super.dispose();
  }
}

// Event classes

class GameStateEvent {
  final int matchId;
  final String status;
  final List<PlayerState> players;
  final int? startTime;

  GameStateEvent({
    required this.matchId,
    required this.status,
    required this.players,
    this.startTime,
  });

  factory GameStateEvent.fromJson(Map<String, dynamic> json) {
    return GameStateEvent(
      matchId: json['matchId'] as int,
      status: json['status'] as String,
      players: (json['players'] as List?)
              ?.map((p) => PlayerState.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      startTime: json['startTime'] as int?,
    );
  }
}

class PlayerState {
  final int oderId;
  final String name;
  final bool isReady;
  final bool isConnected;
  final int score;
  final int tilesRevealed;
  final int mana;

  PlayerState({
    required this.oderId,
    required this.name,
    required this.isReady,
    required this.isConnected,
    required this.score,
    required this.tilesRevealed,
    required this.mana,
  });

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    return PlayerState(
      oderId: json['userId'] as int,
      name: json['name'] as String? ?? 'Player',
      isReady: json['isReady'] as bool? ?? false,
      isConnected: json['isConnected'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      tilesRevealed: json['tilesRevealed'] as int? ?? 0,
      mana: json['mana'] as int? ?? 100,
    );
  }
}

class PlayerJoinedEvent {
  final int matchId;
  final int userId;
  final String name;

  PlayerJoinedEvent({
    required this.matchId,
    required this.userId,
    required this.name,
  });

  factory PlayerJoinedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerJoinedEvent(
      matchId: json['matchId'] as int,
      userId: json['userId'] as int,
      name: json['name'] as String? ?? 'Player',
    );
  }
}

class PlayerReadyEvent {
  final int matchId;
  final int userId;
  final bool isReady;

  PlayerReadyEvent({
    required this.matchId,
    required this.userId,
    required this.isReady,
  });

  factory PlayerReadyEvent.fromJson(Map<String, dynamic> json) {
    return PlayerReadyEvent(
      matchId: json['matchId'] as int,
      userId: json['userId'] as int,
      isReady: json['isReady'] as bool? ?? false,
    );
  }
}

class GameStartingEvent {
  final int matchId;
  final int countdown;

  GameStartingEvent({
    required this.matchId,
    required this.countdown,
  });

  factory GameStartingEvent.fromJson(Map<String, dynamic> json) {
    return GameStartingEvent(
      matchId: json['matchId'] as int,
      countdown: json['countdown'] as int? ?? 3,
    );
  }
}

class GameStartedEvent {
  final int matchId;
  final String boardSeed;
  final int boardWidth;
  final int boardHeight;
  final int mineCount;

  GameStartedEvent({
    required this.matchId,
    required this.boardSeed,
    required this.boardWidth,
    required this.boardHeight,
    required this.mineCount,
  });

  factory GameStartedEvent.fromJson(Map<String, dynamic> json) {
    return GameStartedEvent(
      matchId: json['matchId'] as int,
      boardSeed: json['boardSeed'] as String? ?? '',
      boardWidth: json['boardWidth'] as int? ?? 16,
      boardHeight: json['boardHeight'] as int? ?? 16,
      mineCount: json['mineCount'] as int? ?? 40,
    );
  }
}

class ActionPerformedEvent {
  final int matchId;
  final int userId;
  final String action;
  final int row;
  final int col;
  final bool success;
  final bool hitMine;

  ActionPerformedEvent({
    required this.matchId,
    required this.userId,
    required this.action,
    required this.row,
    required this.col,
    required this.success,
    required this.hitMine,
  });

  factory ActionPerformedEvent.fromJson(Map<String, dynamic> json) {
    return ActionPerformedEvent(
      matchId: json['matchId'] as int,
      userId: json['userId'] as int,
      action: json['action'] as String,
      row: json['row'] as int,
      col: json['col'] as int,
      success: json['success'] as bool? ?? true,
      hitMine: json['hitMine'] as bool? ?? false,
    );
  }
}

class ProgressUpdatedEvent {
  final int matchId;
  final int userId;
  final int score;
  final int tilesRevealed;
  final int mana;

  ProgressUpdatedEvent({
    required this.matchId,
    required this.userId,
    required this.score,
    required this.tilesRevealed,
    required this.mana,
  });

  factory ProgressUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return ProgressUpdatedEvent(
      matchId: json['matchId'] as int,
      userId: json['userId'] as int,
      score: json['score'] as int? ?? 0,
      tilesRevealed: json['tilesRevealed'] as int? ?? 0,
      mana: json['mana'] as int? ?? 100,
    );
  }
}

class SpellCastEvent {
  final int matchId;
  final int casterId;
  final int targetId;
  final String spellType;
  final int duration;

  SpellCastEvent({
    required this.matchId,
    required this.casterId,
    required this.targetId,
    required this.spellType,
    required this.duration,
  });

  factory SpellCastEvent.fromJson(Map<String, dynamic> json) {
    return SpellCastEvent(
      matchId: json['matchId'] as int,
      casterId: json['casterId'] as int,
      targetId: json['targetId'] as int,
      spellType: json['spellType'] as String,
      duration: json['duration'] as int? ?? 0,
    );
  }
}

class PlayerFinishedEvent {
  final int matchId;
  final int userId;
  final bool won;
  final bool hitMine;
  final int score;
  final int completionTime;

  PlayerFinishedEvent({
    required this.matchId,
    required this.userId,
    required this.won,
    required this.hitMine,
    required this.score,
    required this.completionTime,
  });

  factory PlayerFinishedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerFinishedEvent(
      matchId: json['matchId'] as int,
      userId: json['userId'] as int,
      won: json['won'] as bool? ?? false,
      hitMine: json['hitMine'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      completionTime: json['completionTime'] as int? ?? 0,
    );
  }
}

class GameOverEvent {
  final int matchId;
  final int? winnerId;
  final String reason;
  final List<PlayerResult> results;

  GameOverEvent({
    required this.matchId,
    this.winnerId,
    required this.reason,
    required this.results,
  });

  factory GameOverEvent.fromJson(Map<String, dynamic> json) {
    return GameOverEvent(
      matchId: json['matchId'] as int,
      winnerId: json['winnerId'] as int?,
      reason: json['reason'] as String? ?? 'completed',
      results: (json['results'] as List?)
              ?.map((r) => PlayerResult.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class PlayerResult {
  final int userId;
  final int score;
  final int tilesRevealed;
  final int? completionTime;
  final bool isWinner;

  PlayerResult({
    required this.userId,
    required this.score,
    required this.tilesRevealed,
    this.completionTime,
    required this.isWinner,
  });

  factory PlayerResult.fromJson(Map<String, dynamic> json) {
    return PlayerResult(
      userId: json['userId'] as int,
      score: json['score'] as int? ?? 0,
      tilesRevealed: json['tilesRevealed'] as int? ?? 0,
      completionTime: json['completionTime'] as int?,
      isWinner: json['isWinner'] as bool? ?? false,
    );
  }
}

class PlayerDisconnectedEvent {
  final int matchId;
  final int userId;

  PlayerDisconnectedEvent({
    required this.matchId,
    required this.userId,
  });

  factory PlayerDisconnectedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerDisconnectedEvent(
      matchId: json['matchId'] as int,
      userId: json['userId'] as int,
    );
  }
}

class PlayerReconnectedEvent {
  final int matchId;
  final int userId;

  PlayerReconnectedEvent({
    required this.matchId,
    required this.userId,
  });

  factory PlayerReconnectedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerReconnectedEvent(
      matchId: json['matchId'] as int,
      userId: json['userId'] as int,
    );
  }
}

class ChatMessageEvent {
  final int matchId;
  final int userId;
  final String name;
  final String message;
  final DateTime timestamp;

  ChatMessageEvent({
    required this.matchId,
    required this.userId,
    required this.name,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessageEvent.fromJson(Map<String, dynamic> json) {
    return ChatMessageEvent(
      matchId: json['matchId'] as int,
      userId: json['userId'] as int,
      name: json['name'] as String? ?? 'Player',
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}
