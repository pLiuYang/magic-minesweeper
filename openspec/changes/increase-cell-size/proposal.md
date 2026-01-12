# Increase Game Cell Size

## Summary

Refine the game_screen UX by increasing the cell size to improve touch target area and overall playability. The current cell size range of 32–44px is too small for comfortable gameplay on mobile devices.

## Change Overview

| Aspect | Current | Proposed |
|--------|---------|----------|
| Minimum cell size | 32px | 40px |
| Maximum cell size | 44px | 56px |
| Affected widgets | `game_board_widget.dart`, `versus_board_widget.dart` | Same |

## Motivation

- **Better touch targets**: Larger cells reduce accidental taps on adjacent cells
- **Improved visibility**: Numbers and icons become more readable
- **Mobile-first UX**: Aligns with platform touch target guidelines (≥44px recommended)

## Scope

- Single-player game board (`GameBoardWidget`)
- Versus mode game board (`VersusBoardWidget`)
- Cell widget icon/font scaling (automatic via existing `cellSize` parameter)

## Related Capabilities

This change affects the **game-board-display** capability.

## Status

- [ ] Approved for implementation
