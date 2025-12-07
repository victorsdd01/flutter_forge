# {{project_name}}

A Flutter project using BLoC for state management with Clean Architecture.

## Architecture

This project follows Clean Architecture principles with BLoC pattern:

- **Application Layer**: Dependency injection, routes, theme, localization
- **Core Layer**: Errors, network, services, utils, shared utilities
- **Features Layer**: Modular features with Clean Architecture (data/domain/presentation)
- **Shared Layer**: Shared widgets and pages

## State Management

This project uses **BLoC (Business Logic Component)** pattern with:
- `flutter_bloc` and `bloc` for state management
- `hydrated_bloc` for state persistence
- `freezed` for immutable data classes
- `dartz` for functional programming utilities

## Project Structure

```
lib/
├── application/
│   ├── injector.dart
│   ├── routes/
│   ├── theme/
│   ├── l10n/
│   └── constants/
├── core/
│   ├── errors/
│   ├── network/
│   ├── services/
│   ├── utils/
│   ├── states/
│   └── shared/
├── features/
│   └── [feature_name]/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── use_cases/
│       └── presentation/
│           ├── blocs/
│           ├── pages/
│           └── widgets/
└── shared/
    ├── pages/
    └── widgets/
```

## Getting Started

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Generate freezed files:
   ```bash
   dart run build_runner build -d
   ```

3. Generate localization files:
   ```bash
   dart run intl_utils:generate
   ```

4. Run the app:
   ```bash
   flutter run
   ```

## Key Features

- Clean Architecture
- BLoC State Management with HydratedBloc
- Dependency Injection with GetIt
- Navigation with GoRouter
- Immutable State with Freezed
- Functional Programming with Dartz
- Internationalization support 