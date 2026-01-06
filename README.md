# Magic Sweeper

A magical twist on the classic Minesweeper game with spells, multiplayer battles, and a vibrant Candy Crush-inspired design. Built with Flutter for Web and Android.

## Features

### Phase 1: Core Game ✅
- Classic Minesweeper gameplay with all standard rules
- Three difficulty levels: Beginner (8×8), Intermediate (10×10), Expert (12×12)
- Candy Crush-inspired UI with glossy 3D effects and vibrant gradients
- Timer and flag counter with animated status bar
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
- **Visual Effects**: Animated scan highlights, shield indicator, purify sparkles

### Phase 3: Multiplayer ✅
- **Race Mode**: Compete to complete the same board fastest
- **Versus Mode**: Head-to-head battles with competitive spells
- **Co-op Mode**: Work together on a shared board
- **Leaderboards**: Global rankings with daily/weekly/all-time filters
- **AI Opponent**: Practice against intelligent AI locally

#### Competitive Spells (Versus Mode)

| Spell | Cost | Duration | Effect |
|-------|------|----------|--------|
| Curse | 50 MP | 1 action | Opponent's next click does nothing |
| Minefield | 75 MP | 10s | Shows fake mine warnings on opponent's board |
| Mana Drain | 60 MP | Instant | Steal 30 mana from opponent |
| Blind | 80 MP | 5s | Hides all numbers on opponent's board |
| Freeze | 90 MP | 3s | Freezes opponent's controls |
| Scramble | 70 MP | 8s | Randomizes displayed numbers |

## Screenshots

The game features a Candy Crush-inspired design with:
- Vibrant pink, purple, and gold color palette
- Glossy 3D button effects with shadows
- Animated spell effects and cell reveals
- Split-screen multiplayer view
- Responsive design for all screen sizes

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Dart SDK

### Installation

```bash
# Clone the repository
git clone https://github.com/pLiuYang/magic-minesweeper.git
cd magic-minesweeper

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

### Multiplayer
1. Tap "Multiplayer" from the main menu
2. Choose a game mode (Race, Versus, or Co-op)
3. Configure difficulty and time limit
4. Battle against AI or wait for online opponents
5. In Versus mode, use competitive spells to sabotage your opponent!

### Tips
- Use Reveal spell when you're unsure about a tile
- Scan is great for checking suspicious areas
- Save Shield for risky moves
- Purify is expensive but can clear large safe areas
- In Versus mode, time your Freeze spell for maximum disruption

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/
│   ├── cell.dart                # Cell model
│   ├── game_board.dart          # Game board logic
│   ├── game_settings.dart       # Settings model
│   ├── spell.dart               # Single-player spell definitions
│   ├── player.dart              # Player profile and stats
│   ├── multiplayer_match.dart   # Match state and configuration
│   ├── leaderboard_entry.dart   # Leaderboard data model
│   └── competitive_spell.dart   # Versus mode spells
├── providers/
│   ├── game_provider.dart       # Single-player game state
│   ├── settings_provider.dart   # Settings management
│   └── multiplayer_provider.dart # Multiplayer state management
├── screens/
│   ├── main_menu_screen.dart
│   ├── difficulty_selection_screen.dart
│   ├── game_screen.dart
│   ├── victory_screen.dart
│   ├── settings_screen.dart
│   ├── multiplayer_menu_screen.dart
│   ├── multiplayer_lobby_screen.dart
│   ├── versus_game_screen.dart
│   ├── multiplayer_result_screen.dart
│   └── leaderboard_screen.dart
├── widgets/
│   ├── cell_widget.dart
│   ├── game_board_widget.dart
│   ├── status_bar_widget.dart
│   ├── spell_bar_widget.dart
│   ├── menu_button.dart
│   ├── versus_board_widget.dart
│   └── competitive_spell_bar.dart
└── utils/
    └── constants.dart           # Colors, difficulty configs
```

## Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Provider
- **Local Storage**: SharedPreferences
- **Platforms**: Web, Android

## Roadmap

- [x] Phase 1: Core Minesweeper gameplay
- [x] Phase 2: Magic spell system
- [x] Phase 3: Multiplayer modes
- [ ] Phase 4: Online matchmaking with backend
- [ ] Phase 5: Achievements and rewards
- [ ] Phase 6: Daily challenges

## License

This project is open source and available under the MIT License.

## Acknowledgments

- Classic Minesweeper for the original gameplay concept
- Candy Crush Saga for UI/UX design inspiration
- Flutter team for the amazing framework
