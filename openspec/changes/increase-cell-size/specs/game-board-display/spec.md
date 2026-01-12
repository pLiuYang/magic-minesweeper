# game-board-display

Defines how the Minesweeper game board cells are rendered and sized.

## MODIFIED Requirements

### Requirement: Cell Size Bounds

The system SHALL size game board cells within a minimum bound of **40px** (increased from 32px) and a maximum bound of **56px** (increased from 44px) to ensure playability across different screen sizes.

The system SHALL maintain a square aspect ratio (1:1) for all cells.

The system SHALL calculate cell size to fit available screen space while respecting these bounds.

#### Scenario: Small Screen Device

**Given** a device with limited screen width (e.g., 320px viewport)
**When** the game board is rendered for Beginner difficulty (8×8 grid)
**Then** cells shall be sized at minimum 40px each
**And** horizontal scrolling via `InteractiveViewer` is enabled if board exceeds viewport

#### Scenario: Large Screen Device

**Given** a device with ample screen space (e.g., tablet or desktop)
**When** the game board is rendered
**Then** cells shall be sized at maximum 56px each
**And** the board is centered within the available space

#### Scenario: Versus Mode Board

**Given** the versus game screen with two boards displayed
**When** boards are rendered
**Then** each board's cells shall respect the minimum 40px size
**And** boards may use smaller sizing only if constrained by split-screen layout
