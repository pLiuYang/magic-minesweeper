# Magic MineSweeper

A modern Minesweeper game built with Flutter, featuring magical powers and multiplayer capabilities (coming soon).

## Features

### Phase 1 (Current) - Core Game MVP
- ✅ Classic Minesweeper gameplay with all standard rules
- ✅ Three difficulty levels: Beginner (9×9), Intermediate (16×16), Expert (30×16)
- ✅ Tap to reveal cells, long-press to flag
- ✅ Chording support (tap revealed numbers to auto-reveal neighbors)
- ✅ Timer and flag counter
- ✅ Victory/Game Over screens with statistics
- ✅ Best time tracking per difficulty
- ✅ Settings screen with sound/vibration toggles
- ✅ Polished UI based on design specifications

### Phase 2 (Planned) - Magic System
- Mana system gained by clearing tiles
- Spells: Reveal, Scan, Shield, Disarm, Teleport, Purify
- Spell selection interface
- Visual effects for spell casting

### Phase 3 (Planned) - Multiplayer
- User accounts and authentication
- Race mode, Versus mode, Co-op mode
- Online leaderboards
- Player profiles and rankings

### Phase 4 (Planned) - Expansion
- Cosmetics and spell packs
- New game modes and challenges
- Additional content

## Getting Started

### Prerequisites
- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher

### Installation

1. Clone the repository:
```bash
git clone https://github.com/pLiuYang/magic-minesweeper.git
cd magic-minesweeper
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
# For web
flutter run -d chrome

# For Android
flutter run -d android
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   ├── cell.dart            # Cell state model
│   ├── game_board.dart      # Game board model with logic
│   └── game_settings.dart   # Settings and stats models
├── providers/
│   ├── game_provider.dart   # Game state management
│   └── settings_provider.dart # Settings persistence
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
│   ├── spell_bar_widget.dart  # Placeholder for Phase 2
│   └── menu_button.dart
└── utils/
    └── constants.dart        # Colors, styles, configurations
```

## How to Play

1. **Objective**: Uncover all non-mine tiles on the grid
2. **Tap**: Reveal a cell
3. **Long-press**: Toggle flag on a cell
4. **Numbers**: Indicate how many mines are adjacent to that cell
5. **Chording**: Tap a revealed number when all adjacent mines are flagged to auto-reveal remaining neighbors
6. **Win**: Reveal all safe cells
7. **Lose**: Reveal a mine

## Technical Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Platforms**: Web, Android

## License

This project is licensed under the MIT License.

## Acknowledgments

- Design inspired by classic Minesweeper with a modern magical twist
- Built as part of the Magic MineSweeper project
