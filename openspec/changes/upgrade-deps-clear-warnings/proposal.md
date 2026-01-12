# Change: Upgrade Pub Dependencies and Clear All Warnings

## Why
The project has 282 analyzer warnings (mostly deprecated API usage) and 21 outdated dependencies. Keeping dependencies current improves security, stability, and access to the latest features. Clearing warnings ensures code quality and prevents deprecated API usage from breaking in future Flutter releases.

## What Changes
- **BREAKING**: Upgrade `flutter_lints` from 3.0.2 → 6.0.0 (major version bump, stricter lint rules)
- Upgrade direct dependencies: `shared_preferences`, `url_launcher`, `webview_flutter`
- Replace all `Color.withOpacity()` calls with `Color.withValues()` (238 occurrences)
- Add `const` to constructors/literals where suggested (32 occurrences)
- Remove unused imports and dead code (10 warnings)

## Impact
- Affected specs: code-quality (new capability)
- Affected code:
  - `pubspec.yaml` - dependency versions
  - All files in `lib/screens/` and `lib/widgets/` - withOpacity → withValues
  - `lib/providers/game_provider.dart` - unused element removal
  - `lib/widgets/competitive_spell_bar.dart` - unused variable
  - `lib/models/game_board.dart` - unused import
