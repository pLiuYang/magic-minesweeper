import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_config.dart';

/// WebSocket service for real-time multiplayer communication
class SocketService extends ChangeNotifier {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  int? _currentMatchId;
  int? _currentUserId;

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
      _socket = IO.io(
        ApiConfig.baseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setPath(ApiConfig.socketPath)
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .build(),
      );

      _setupEventListeners();

      final completer = Completer<bool>();
      
      _socket!.onConnect((_) {
        _isConnected = true;
        notifyListeners();
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      });

      _socket!.onConnectError((error) {
        _isConnected = false;
        notifyListeners();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      _socket!.connect();

      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => false,
      );
    } catch (e) {
      debugPrint('Socket connection error: $e');
      return false;
    }
  }

  /// Setup event listeners
  void _setupEventListeners() {
    _socket!.on('game_state', (data) {
      _gameStateController.add(GameStateEvent.fromJson(data));
    });

    _socket!.on('player_joined', (data) {
      _playerJoinedController.add(PlayerJoinedEvent.fromJson(data));
    });

    _socket!.on('player_ready_changed', (data) {
      _playerReadyController.add(PlayerReadyEvent.fromJson(data));
    });

    _socket!.on('game_starting', (data) {
      _gameStartingController.add(GameStartingEvent.fromJson(data));
    });

    _socket!.on('game_started', (data) {
      _gameStartedController.add(GameStartedEvent.fromJson(data));
    });

    _socket!.on('action_performed', (data) {
      _actionPerformedController.add(ActionPerformedEvent.fromJson(data));
    });

    _socket!.on('progress_updated', (data) {
      _progressUpdatedController.add(ProgressUpdatedEvent.fromJson(data));
    });

    _socket!.on('spell_cast', (data) {
      _spellCastController.add(SpellCastEvent.fromJson(data));
    });

    _socket!.on('player_finished', (data) {
      _playerFinishedController.add(PlayerFinishedEvent.fromJson(data));
    });

    _socket!.on('game_over', (data) {
      _gameOverController.add(GameOverEvent.fromJson(data));
    });

    _socket!.on('player_disconnected', (data) {
      _playerDisconnectedController.add(PlayerDisconnectedEvent.fromJson(data));
    });

    _socket!.on('player_reconnected', (data) {
      _playerReconnectedController.add(PlayerReconnectedEvent.fromJson(data));
    });

    _socket!.on('chat_message', (data) {
      _chatMessageController.add(ChatMessageEvent.fromJson(data));
    });

    _socket!.on('error', (data) {
      _errorController.add(data['message'] ?? 'Unknown error');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      notifyListeners();
    });

    _socket!.onReconnect((_) {
      _isConnected = true;
      notifyListeners();
      // Rejoin game if was in one
      if (_currentMatchId != null && _currentUserId != null) {
        reconnectGame(_currentMatchId!, _currentUserId!);
      }
    });
  }

  /// Join a game
  void joinGame(int matchId, int userId) {
    _currentMatchId = matchId;
    _currentUserId = userId;
    _socket?.emit('join_game', {
      'matchId': matchId,
      'userId': userId,
    });
  }

  /// Set player ready status
  void setReady(int matchId, bool ready) {
    _socket?.emit('player_ready', {
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
    _socket?.emit('player_action', {
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
    _socket?.emit('update_progress', {
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
    _socket?.emit('cast_spell', {
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
    _socket?.emit('player_finished', {
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
    _socket?.emit('reconnect_game', {
      'matchId': matchId,
      'userId': userId,
    });
  }

  /// Send a chat message
  void sendChatMessage(int matchId, String message) {
    _socket?.emit('chat_message', {
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
    _socket?.disconnect();
    _socket?.dispose();
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
              ?.map((e) => PlayerState.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      startTime: json['startTime'] as int?,
    );
  }
}

class PlayerState {
  final int oderId;
  final String displayName;
  final bool isReady;
  final bool isConnected;
  final int score;
  final int tilesRevealed;
  final int mana;
  final bool hasFinished;
  final bool won;
  final bool hitMine;

  PlayerState({
    required this.oderId,
    required this.displayName,
    required this.isReady,
    required this.isConnected,
    required this.score,
    required this.tilesRevealed,
    required this.mana,
    required this.hasFinished,
    required this.won,
    required this.hitMine,
  });

  factory PlayerState.fromJson(Map<String, dynamic> json) {
    return PlayerState(
      oderId: json['oderId'] as int,
      displayName: json['displayName'] as String? ?? 'Player',
      isReady: json['isReady'] as bool? ?? false,
      isConnected: json['isConnected'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      tilesRevealed: json['tilesRevealed'] as int? ?? 0,
      mana: json['mana'] as int? ?? 0,
      hasFinished: json['hasFinished'] as bool? ?? false,
      won: json['won'] as bool? ?? false,
      hitMine: json['hitMine'] as bool? ?? false,
    );
  }
}

class PlayerJoinedEvent {
  final int oderId;
  final String displayName;
  final int playerCount;

  PlayerJoinedEvent({
    required this.oderId,
    required this.displayName,
    required this.playerCount,
  });

  factory PlayerJoinedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerJoinedEvent(
      oderId: json['oderId'] as int,
      displayName: json['displayName'] as String? ?? 'Player',
      playerCount: json['playerCount'] as int? ?? 1,
    );
  }
}

class PlayerReadyEvent {
  final int oderId;
  final bool ready;

  PlayerReadyEvent({required this.oderId, required this.ready});

  factory PlayerReadyEvent.fromJson(Map<String, dynamic> json) {
    return PlayerReadyEvent(
      oderId: json['oderId'] as int,
      ready: json['ready'] as bool? ?? false,
    );
  }
}

class GameStartingEvent {
  final int countdown;

  GameStartingEvent({required this.countdown});

  factory GameStartingEvent.fromJson(Map<String, dynamic> json) {
    return GameStartingEvent(
      countdown: json['countdown'] as int? ?? 3,
    );
  }
}

class GameStartedEvent {
  final int startTime;
  final String boardSeed;

  GameStartedEvent({required this.startTime, required this.boardSeed});

  factory GameStartedEvent.fromJson(Map<String, dynamic> json) {
    return GameStartedEvent(
      startTime: json['startTime'] as int,
      boardSeed: json['boardSeed'] as String,
    );
  }
}

class ActionPerformedEvent {
  final int oderId;
  final String action;
  final int row;
  final int col;
  final int timestamp;

  ActionPerformedEvent({
    required this.oderId,
    required this.action,
    required this.row,
    required this.col,
    required this.timestamp,
  });

  factory ActionPerformedEvent.fromJson(Map<String, dynamic> json) {
    return ActionPerformedEvent(
      oderId: json['oderId'] as int,
      action: json['action'] as String,
      row: json['row'] as int,
      col: json['col'] as int,
      timestamp: json['timestamp'] as int,
    );
  }
}

class ProgressUpdatedEvent {
  final int oderId;
  final int score;
  final int tilesRevealed;
  final int mana;

  ProgressUpdatedEvent({
    required this.oderId,
    required this.score,
    required this.tilesRevealed,
    required this.mana,
  });

  factory ProgressUpdatedEvent.fromJson(Map<String, dynamic> json) {
    return ProgressUpdatedEvent(
      oderId: json['oderId'] as int,
      score: json['score'] as int? ?? 0,
      tilesRevealed: json['tilesRevealed'] as int? ?? 0,
      mana: json['mana'] as int? ?? 0,
    );
  }
}

class SpellCastEvent {
  final int casterId;
  final int targetId;
  final String spellType;
  final int duration;
  final int timestamp;

  SpellCastEvent({
    required this.casterId,
    required this.targetId,
    required this.spellType,
    required this.duration,
    required this.timestamp,
  });

  factory SpellCastEvent.fromJson(Map<String, dynamic> json) {
    return SpellCastEvent(
      casterId: json['casterId'] as int,
      targetId: json['targetId'] as int,
      spellType: json['spellType'] as String,
      duration: json['duration'] as int,
      timestamp: json['timestamp'] as int,
    );
  }
}

class PlayerFinishedEvent {
  final int oderId;
  final bool won;
  final bool hitMine;
  final int score;
  final int completionTime;

  PlayerFinishedEvent({
    required this.oderId,
    required this.won,
    required this.hitMine,
    required this.score,
    required this.completionTime,
  });

  factory PlayerFinishedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerFinishedEvent(
      oderId: json['oderId'] as int,
      won: json['won'] as bool? ?? false,
      hitMine: json['hitMine'] as bool? ?? false,
      score: json['score'] as int? ?? 0,
      completionTime: json['completionTime'] as int? ?? 0,
    );
  }
}

class GameOverEvent {
  final int? winnerId;
  final int duration;
  final List<GameResult> results;

  GameOverEvent({
    this.winnerId,
    required this.duration,
    required this.results,
  });

  factory GameOverEvent.fromJson(Map<String, dynamic> json) {
    return GameOverEvent(
      winnerId: json['winnerId'] as int?,
      duration: json['duration'] as int? ?? 0,
      results: (json['results'] as List?)
              ?.map((e) => GameResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class GameResult {
  final int oderId;
  final int score;
  final int completionTime;
  final bool isWinner;
  final bool hitMine;

  GameResult({
    required this.oderId,
    required this.score,
    required this.completionTime,
    required this.isWinner,
    required this.hitMine,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      oderId: json['oderId'] as int,
      score: json['score'] as int? ?? 0,
      completionTime: json['completionTime'] as int? ?? 0,
      isWinner: json['isWinner'] as bool? ?? false,
      hitMine: json['hitMine'] as bool? ?? false,
    );
  }
}

class PlayerDisconnectedEvent {
  final int oderId;

  PlayerDisconnectedEvent({required this.oderId});

  factory PlayerDisconnectedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerDisconnectedEvent(
      oderId: json['oderId'] as int,
    );
  }
}

class PlayerReconnectedEvent {
  final int oderId;

  PlayerReconnectedEvent({required this.oderId});

  factory PlayerReconnectedEvent.fromJson(Map<String, dynamic> json) {
    return PlayerReconnectedEvent(
      oderId: json['oderId'] as int,
    );
  }
}

class ChatMessageEvent {
  final int oderId;
  final String displayName;
  final String message;
  final int timestamp;

  ChatMessageEvent({
    required this.oderId,
    required this.displayName,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessageEvent.fromJson(Map<String, dynamic> json) {
    return ChatMessageEvent(
      oderId: json['oderId'] as int,
      displayName: json['displayName'] as String? ?? 'Player',
      message: json['message'] as String,
      timestamp: json['timestamp'] as int,
    );
  }
}
