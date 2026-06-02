# CadenceIQ

AI-powered cycling training and performance platform — Flutter MVP with mock data only.

## Features

- Splash & 4-screen onboarding flow
- Authentication (login, signup, social placeholders)
- Dashboard with CTL/ATL/TSB metrics, charts, and today's session
- Activities list (28 mock rides) with search, filters, and detail views
- Goals (current/past tabs), goal details, and AI plan generation UI
- Completed goal summaries with insights and badges
- Settings (dark mode, units, notifications, connected services)
- Profile with performance stats

## Tech Stack

- Flutter 3.x
- Provider (state management)
- Go Router (navigation)
- Material 3
- fl_chart (charts)
- google_fonts

## Getting Started

```bash
flutter pub get
flutter run
```

### Demo Login

- Email: any valid email (pre-filled `alex.morgan@example.com`)
- Password: 6+ characters (pre-filled `password123`)

Social login buttons navigate directly to the dashboard for demo purposes.

## Architecture

```
lib/
├── core/           # theme, constants, widgets, utils, navigation
├── features/       # feature screens by module
├── models/         # data models
├── providers/      # ChangeNotifier providers
├── services/mock/  # mock repositories & data
└── main.dart
```

## Backend Integration

All data comes from `lib/services/mock/`. To integrate APIs later:

1. Replace mock repositories with real implementations
2. Keep the same model classes and provider interfaces
3. Add network/error handling in providers

## License

Private — CadenceIQ MVP
