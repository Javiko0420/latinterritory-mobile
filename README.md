# LatinTerritory Mobile

Flutter mobile app for [LatinTerritory](https://www.latinterritory.com) — a community platform for Latinos abroad.

## Tech Stack

| Category | Tool |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Riverpod + Code Generation |
| HTTP Client | Dio (with auth interceptor) |
| Routing | GoRouter |
| Secure Storage | flutter_secure_storage |
| Models | Freezed + json_serializable |
| Environment | envied |

## Getting Started

### Prerequisites
- Flutter SDK >= 3.5.0
- Xcode (for iOS)
- Android Studio (for Android)

### Setup

```bash
# 1. Clone the repo
git clone <repo-url>
cd latinterritory-mobile

# 2. Copy environment files (in project root)
cp .env.development.example .env.development
cp .env.production.example .env.production
# Edit with your BASE_URL and Google OAuth client IDs

# 3. Install dependencies
flutter pub get

# 4. Run code generation (freezed, json_serializable, envied)
dart run build_runner build --delete-conflicting-outputs

# 5. Run the app
flutter run
```

### Code Generation

After modifying any file that uses `@freezed`, `@JsonSerializable`, `@Envied`, or `@riverpod` annotations:

```bash
# One-time build
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-rebuild on save)
dart run build_runner watch --delete-conflicting-outputs
```

## Project Structure

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp config
├── core/                     # App-wide infrastructure
│   ├── config/               # Environment, app settings
│   ├── constants/            # Colors, dimensions, API routes
│   ├── networking/           # Dio client, interceptors
│   ├── routing/              # GoRouter config
│   ├── storage/              # Secure token storage
│   └── theme/                # Material 3 theme
├── features/                 # Feature-first modules
│   ├── auth/                 # Authentication
│   ├── home/                 # Dashboard
│   ├── businesses/           # Business directory
│   ├── jobs/                 # Job listings
│   ├── events/               # Events
│   ├── forums/               # Community forums
│   ├── profile/              # User profile
│   ├── weather/              # Weather widget
│   └── sports/               # Sports data
└── shared/                   # Reusable widgets & utilities
    ├── widgets/              # lt_ prefixed components
    ├── extensions/           # Dart extensions
    └── utils/                # Validators, logger, formatters
```

## Backend APIs

This app connects to the LatinTerritory Next.js backend. Some APIs exist, others need to be created:

- ✅ Auth (register, forgot-password)
- ✅ Forums (full CRUD)
- ✅ Weather, Exchange Rates, Sports
- ⚠️ **Needs creation:** `/api/auth/mobile/*` (login, refresh, google)
- ⚠️ **Needs creation:** `/api/businesses`, `/api/jobs`, `/api/events`

See `docs/` folder for API contract specifications.

## Git Conventions

```
feat: add login screen with email/password
fix: resolve token refresh race condition
refactor: extract auth interceptor logic
docs: add API contract for mobile login
chore: update dependencies
```

## License

Private — LatinTerritory © 2025
