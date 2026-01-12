## ADDED Requirements

### Requirement: Zero Analyzer Warnings
The project MUST pass `flutter analyze` with zero warnings and zero info-level issues.

#### Scenario: Clean analyzer output
- **WHEN** running `flutter analyze` on the project
- **THEN** the command outputs "No issues found"

### Requirement: Up-to-Date Dependencies
The project MUST maintain dependencies at the latest compatible versions.

#### Scenario: Direct dependencies are current
- **WHEN** running `flutter pub outdated`
- **THEN** all direct dependencies show Current = Resolvable = Latest OR have documented reasons for version pinning

### Requirement: No Deprecated API Usage
The codebase MUST NOT use deprecated Flutter/Dart APIs that have non-deprecated alternatives.

#### Scenario: Color opacity manipulation uses modern API
- **WHEN** setting color opacity values
- **THEN** code uses `Color.withValues(alpha: X)` instead of deprecated `Color.withOpacity(X)`

### Requirement: Const Optimization
Widgets and literals MUST use `const` constructors where possible to improve performance.

#### Scenario: Immutable widgets are const
- **WHEN** a widget constructor has only compile-time constant arguments
- **THEN** the constructor call uses the `const` keyword
