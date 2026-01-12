# Project Context

## Purpose
Magic Sweeper is a Flutter-based magical twist on the classic Minesweeper game featuring spells, multiplayer battles, and a vibrant Neo-Retro gaming design. Built for Web and Android platforms.

### Key Features
- Classic Minesweeper gameplay with three difficulty levels
- Magic spell system with 6 unique spells (Reveal, Scan, Disarm, Shield, Teleport, Purify)
- Multiplayer modes: Race, Versus, and Co-op
- Competitive spells for Versus mode (Curse, Minefield, Mana Drain, Blind, Freeze, Scramble)
- Local statistics tracking and leaderboards

## Tech Stack
- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Platforms**: Web (primary), Android, iOS (basic support)
- **Linting**: flutter_lints (recommended lints)

## Project Conventions

### Code Style
- Follow Dart's official style guide and flutter_lints recommendations
- Use `flutter analyze` to check for lint issues
- File naming: lowercase with underscores (e.g., `game_board.dart`)
- Class naming: PascalCase (e.g., `GameProvider`)
- Private members: prefix with underscore (e.g., `_buildWidget`)

### Architecture Patterns
**Provider-based MVVM architecture:**

```
lib/
├── main.dart              # App entry with MaterialApp and providers
├── models/                # Data models (Cell, GameBoard, Spell, Player, etc.)
├── providers/             # State management (GameProvider, SettingsProvider, MultiplayerProvider)
├── viewmodels/            # MVVM view models
├── screens/               # Full page UI screens
├── widgets/               # Reusable UI components
├── services/              # Business logic services
├── views/                 # MVVM views
└── utils/constants.dart   # Colors, theme tokens, difficulty configs
```

**Key Providers:**
- `GameProvider` - Single-player game state, board logic, spell casting
- `SettingsProvider` - Sound, vibration, and user preferences
- `MultiplayerProvider` - Multiplayer match state, AI opponent, leaderboards

### Testing Strategy
- Tests located in `test/` directory
- Run all tests: `flutter test`
- Run with coverage: `flutter test --coverage`
- Widget tests for UI components

### Git Workflow
- Feature branches for new development
- Commit messages should be descriptive
- Run `flutter analyze` before committing

## Domain Context

### Game Mechanics
- **Cell States**: Hidden, Revealed, Flagged, Mine
- **Mana System**: Earn mana by revealing tiles, spend to cast spells
- **Chord**: Tap on a number to auto-reveal neighbors when flags match

### Spell Costs
| Spell    | Cost   |
|----------|--------|
| Reveal   | 10 MP  |
| Scan     | 20 MP  |
| Disarm   | 30 MP  |
| Shield   | 40 MP  |
| Teleport | 50 MP  |
| Purify   | 80 MP  |

### Difficulty Levels
| Level        | Grid Size |
|--------------|-----------|
| Beginner     | 8×8       |
| Intermediate | 10×10     |
| Expert       | 12×12     |

## Important Constraints
- Web is the primary development platform
- Must maintain Neo-Retro pixel aesthetic (magic purple theme, glossy 3D effects)
- Theme colors defined in `lib/utils/constants.dart`
- UI components should use widgets from `lib/widgets/` for consistency

## External Dependencies
- `provider: ^6.0.0` - State management
- `shared_preferences: ^2.0.0` - Local storage for settings/stats
- `cupertino_icons: ^1.0.2` - iOS-style icons
- `url_launcher: ^6.0.0` - External link handling
- `webview_flutter: ^4.4.0` - Web view embedding
