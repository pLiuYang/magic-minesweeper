# Magic Sweeper

A magical twist on the classic Minesweeper game, built with Flutter for Web and Android.

## Features

### Phase 1: Core Game (MVP) ✅
- Classic Minesweeper gameplay with all standard rules
- Three difficulty levels: Beginner (9×9), Intermediate (16×16), Expert (30×16)
- Polished UI with smooth animations
- Timer and flag counter
- Victory/Game Over screens with star ratings
- Local statistics tracking (games played, win rate, best times)
- Settings for sound and vibration

### Phase 2: Magic System ✅
- **Mana System**: Earn mana by revealing tiles, use it to cast spells
- **6 Unique Spells**:
  | Spell | Cost | Effect |
  |-------|------|--------|
  | Reveal | 10 MP | Safely reveal one tile |
  | Scan | 20 MP | Highlight mines in 3×3 area for 5 seconds |
  | Disarm | 30 MP | Remove a flagged mine permanently |
  | Shield | 40 MP | Survive one mine hit |
  | Teleport | 50 MP | Move a mine to a random location |
  | Purify | 80 MP | Safely clear a 3×3 area |
- **Spell Book**: Customize which 4 spells to equip
- **Visual Effects**: Scan highlights, shield indicator, spell targeting mode

### Phase 3: Multiplayer (Coming Soon)
- Versus mode
- Cooperative mode
- Online leaderboards

## Screenshots

The game features a clean, modern UI with:
- Gradient backgrounds
- Smooth animations
- Intuitive touch controls
- Responsive design for all screen sizes

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Dart SDK

### Installation

```bash
# Clone the repository
git clone https://github.com/pLiuYang/magic-sweeper.git
cd magic-sweeper

# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android

# Build for release
flutter build web --release
flutter build apk --release
```

## How to Play

### Basic Controls
- **Tap**: Reveal a tile
- **Long Press**: Place/remove a flag
- **Tap on Number**: Chord (reveal neighbors if flags match)

### Using Spells
1. Tap a spell in the spell bar at the bottom
2. For targeted spells, tap the cell you want to cast on
3. For Shield, it activates immediately
4. Spells cost mana - earn more by revealing tiles!

### Tips
- Use Reveal spell when you're unsure about a tile
- Scan is great for checking suspicious areas
- Save Shield for risky moves
- Purify is expensive but can clear large safe areas

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   ├── cell.dart          # Cell model
│   ├── game_board.dart    # Game board logic
│   ├── game_settings.dart # Settings model
│   └── spell.dart         # Spell definitions
├── providers/
│   ├── game_provider.dart     # Game state management
│   └── settings_provider.dart # Settings management
├── screens/
│   ├── main_menu_screen.dart
│   ├── difficulty_selection_screen.dart
│   ├── game_screen.dart
│   ├── victory_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── cell_widget.dart
│   ├── game_board_widget.dart
│   ├── status_bar_widget.dart
│   ├── spell_bar_widget.dart
│   └── menu_button.dart
└── utils/
    └── constants.dart     # Colors, difficulty configs
```

## Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Platforms**: Web, Android

## License

This project is open source and available under the MIT License.

## Acknowledgments

- Classic Minesweeper for the original gameplay concept
- Flutter team for the amazing framework
