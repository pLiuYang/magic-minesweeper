# Increase Game Cell Size

## Why

The current cell size range (32–44px) is too small for comfortable gameplay on mobile devices. Larger cells improve touch targets, reduce accidental taps, and align with platform guidelines (≥44px recommended).

## What Changes

| Aspect | Before | After |
|--------|--------|-------|
| Minimum cell size | 32px | 40px |
| Maximum cell size | 44px | 56px |

**Files affected:**
- `game_board_widget.dart` — main game board  
- `versus_board_widget.dart` — versus mode boards

## Status

- [x] Implemented
