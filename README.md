<div align="center">

<img src="docs/logo.svg" width="128" height="128" alt="Tailor Beard Logo" />

# 🪡 Wage Calculator — A Tailor's Day at the Shop

Calculate daily wages with regular and overtime hours across multiple platforms — told through the story of a tailor. ✂️🧵💸

</div>

## Overview
Wage Calculator helps you compute daily pay for one or more workers by splitting time into regular hours (up to 8/day) and overtime, supporting overnight shifts and locale-aware currency formatting.

## Tailor's Workflow (Animated Tour)

Bring the story to life. Drop GIFs into `docs/gifs/` with the suggested names below and they’ll render here.

| Scene | What happens | Demo |
|---|---|---|
| 1. Taking measurements | Set start and end times for the workday | ![Pick time](docs/gifs/select-time.gif)
| 2. Setting the rate | Enter the regular rate and overtime multiplier | ![Type rate](docs/gifs/type-rate.gif)
| 3. Adding apprentices | Add/remove multiple workers | ![Add workers](docs/gifs/add-workers.gif)
| 4. Late-night stitching | Handle overnight shifts seamlessly | ![Overnight shift](docs/gifs/overnight.gif)
| 5. Collecting payment | See totals with currency formatting | ![Results](docs/gifs/results.gif)

Tip: You can record quick GIFs with tools like Kap (macOS) or ScreenToGif (Windows) and place them in `docs/gifs/`.

<details>
<summary>Alternate compact storyboard</summary>

1) 🕘 Start/end time → 2) 💵 Rate/multiplier → 3) ➕ Add workers → 4) 🌙 Overnight → 5) ✅ Total wages

</details>

## Features
- Multiple workers: Add/remove workers dynamically.
- Regular vs Overtime: Auto-splits up to 8 hours as regular; rest as overtime.
- Overnight shifts: Handles end times earlier than start times (rolls to next day).
- Validation and formatting:
  - Numeric input validation with formatters and helpful errors
  - PKR currency formatting via `intl`
- Safer UX: Delete confirmation to prevent accidental removal.
- Localization: Structured i18n with generated l10n (English included).

## Try It (Quick Run)

```bash
flutter pub get
flutter run -d macos   # or ios/android/chrome
```

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

## Assets (Optional)
```text
docs/
  gifs/
    select-time.gif
    type-rate.gif
    add-workers.gif
    overnight.gif
    results.gif
```

## License
Add your license of choice (e.g., MIT) as `LICENSE`.
