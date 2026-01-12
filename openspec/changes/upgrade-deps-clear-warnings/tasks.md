# Tasks: Upgrade Dependencies & Clear Warnings

## 1. Upgrade Dependencies
- [x] 1.1 Update `pubspec.yaml` with latest compatible versions:
  - `flutter_lints: ^6.0.0`
  - `shared_preferences: ^2.5.4`
  - `url_launcher: ^6.3.2`
  - `webview_flutter: ^4.13.1`
- [x] 1.2 Run `flutter pub upgrade` to sync lock file

## 2. Fix withOpacity Deprecations (234 occurrences)
- [x] 2.1 Replace `Color.withOpacity(X)` with `Color.withValues(alpha: X)` in all screen files
- [x] 2.2 Replace deprecated calls in all widget files

## 3. Fix prefer_const and other lint issues
- [x] 3.1 Run `dart fix --apply` for auto-fixable issues (5 fixes)
- [x] 3.2 Fix curly braces lint manually

## 4. Remove Unused Code (10 warnings)
- [x] 4.1 Remove unused imports (7 files)
- [x] 4.2 Remove unused elements:
  - `lib/providers/game_provider.dart` - `_isFirstGame`, `_stopScanTimer`
  - `lib/widgets/competitive_spell_bar.dart` - `cooldownProgress`
- [x] 4.3 Fix deprecated `Color.value` → `Color.toARGB32()`
- [x] 4.4 Add missing type annotation

## 5. Verification
- [x] 5.1 Run `flutter analyze` confirms 0 issues
- [ ] 5.2 Run `flutter test` - Pre-existing timeout issue (unrelated)
- [x] 5.3 Run `flutter build web` confirms build success
