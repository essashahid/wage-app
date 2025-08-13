# Wage Calculator

Calculate daily wages with regular and overtime hours across multiple platforms.

## Overview
Wage Calculator helps you compute daily pay for one or more workers by splitting time into regular hours (up to 8/day) and overtime, supporting overnight shifts and locale-aware currency formatting.

## Features
- Multiple workers: Add/remove workers dynamically.
- Regular vs Overtime: Auto-splits up to 8 hours as regular; rest as overtime.
- Overnight shifts: Handles end times earlier than start times (rolls to next day).
- Validation and formatting:
  - Numeric input validation with formatters and helpful errors
  - PKR currency formatting via `intl`
- Safer UX: Delete confirmation to prevent accidental removal.
- Localization: Structured i18n with generated l10n (English included).

## Getting Started

Prerequisites:
- Flutter SDK ^3.5.0

Install dependencies:
```bash
flutter pub get
```

Run (choose a target):
```bash
# macOS desktop
flutter run -d macos

# iOS Simulator
open -a Simulator
flutter run -d ios

# Android emulator
flutter emulators --launch <id>
flutter run -d <device_id>

# Web (Chrome)
flutter config --enable-web
flutter run -d chrome
```

## Project Structure
```text
lib/
  main.dart                    # App entry, routing, app bar
  models/
    worker.dart                # Worker model with stable id
  utils/
    calculation.dart           # Pure wage calculation logic
  widgets/
    worker_input_card.dart     # Worker form card (controllers + validation)
  l10n/
    app_en.arb                 # English strings
```

## Internationalization
- Uses Flutter's generated l10n.
- To add a language, create another ARB (e.g., `app_ur.arb`) and run the app; Flutter generates the localizations.

## Business Rules
- Regular hours cap: 8 hours/day
- Overtime multiplier: ≥ 1.0
- Regular rate: > 0

## Roadmap
- Break deductions and custom daily caps
- Export/share results (CSV/PDF)
- Persist sessions (local storage)
- Tests for calculation edge cases

## License
Add your license of choice (e.g., MIT) as `LICENSE`.
