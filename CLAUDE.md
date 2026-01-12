# CLAUDE.md - Project Guide for Claude Code

## Project Overview

**Magic Sweeper** is a Flutter-based magical twist on the classic Minesweeper game featuring spells, multiplayer battles, and a vibrant Candy Crush-inspired design. Built for Web and Android platforms.

## Quick Commands

```bash
# Install dependencies
flutter pub get

# Run on web (primary dev platform)
flutter run -d chrome

# Run on Android
flutter run -d android

# Run tests
flutter test

# Analyze code for lint issues
flutter analyze

# Build for release
flutter build web --release
flutter build apk --release
```

## Architecture

The project follows a **Provider-based state management** pattern with MVVM architecture:

```
lib/
├── main.dart              # App entry point with MaterialApp and providers
├── models/                # Data models (Cell, GameBoard, Spell, Player, etc.)
├── providers/             # State management (GameProvider, SettingsProvider, MultiplayerProvider)
├── viewmodels/            # MVVM view models
├── screens/               # Full page UI screens
├── widgets/               # Reusable UI components
├── services/              # Business logic services
├── views/                 # MVVM views
└── utils/
    └── constants.dart     # Colors, theme tokens, difficulty configs
```

### Key Providers
- `GameProvider` - Single-player game state, board logic, spell casting
- `SettingsProvider` - Sound, vibration, and user preferences
- `MultiplayerProvider` - Multiplayer match state, AI opponent, leaderboards

## Design System

The UI uses a **Neo-Retro gaming style** with:
- **Primary colors**: Magic purple (`magicPurple`), vibrant gradients
- **Effects**: Glossy 3D buttons, pixel decorations, animated spell effects
- **Typography**: Sharp, retro-inspired text styling
- **Theme tokens**: Defined in `lib/utils/constants.dart`

## Game Features

### Spell System (6 spells)
| Spell    | Cost   | Effect |
|----------|--------|--------|
| Reveal   | 10 MP  | Safely reveal one tile |
| Scan     | 20 MP  | Highlight mines in 3×3 area |
| Disarm   | 30 MP  | Remove a flagged mine |
| Shield   | 40 MP  | Survive one mine hit |
| Teleport | 50 MP  | Move a mine to random location |
| Purify   | 80 MP  | Safely clear a 3×3 area |

### Multiplayer Modes
- **Race Mode**: Compete to complete the same board fastest
- **Versus Mode**: Head-to-head with competitive spells
- **Co-op Mode**: Work together on a shared board

## Testing

Tests are located in the `test/` directory:
```bash
flutter test              # Run all tests
flutter test --coverage   # Run with coverage
```

## Platform Notes

- **Web**: Primary development platform, use `flutter run -d chrome`
- **Android**: Full support with adaptive icons in `android/app/src/main/res/`
- **iOS**: Basic support with app icons in `ios/Runner/Assets.xcassets/`

## Common Tasks

### Adding a new screen
1. Create screen file in `lib/screens/`
2. Add route in `main.dart` if using named routes
3. Use existing widgets from `lib/widgets/` for consistency

### Modifying game logic
1. Board logic is in `lib/models/game_board.dart`
2. Spell effects are in `lib/models/spell.dart`
3. State changes go through `lib/providers/game_provider.dart`

### Updating UI theme
1. Color constants are in `lib/utils/constants.dart`
2. Button styling is in `lib/widgets/menu_button.dart`
3. Follow the Neo-Retro pixel aesthetic

## Dependencies

Key packages (see `pubspec.yaml`):
- `provider` - State management
- `shared_preferences` - Local storage for settings/stats
