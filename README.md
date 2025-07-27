# FlutterForge

A powerful Flutter CLI tool for creating projects with interactive prompts and state management templates, built with Clean Architecture principles.

## 🏗️ Architecture

This project follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/
│   └── di/
│       └── dependency_injection.dart    # Dependency injection container
├── data/
│   ├── datasources/
│   │   ├── file_system_datasource.dart  # File system operations
│   │   └── flutter_command_datasource.dart # Flutter CLI operations
│   └── repositories/
│       └── project_repository_impl.dart # Repository implementation
├── domain/
│   ├── entities/
│   │   └── project_config.dart          # Core business entities
│   ├── repositories/
│   │   └── project_repository.dart      # Repository interfaces
│   └── usecases/
│       ├── create_project_usecase.dart  # Business logic for project creation
│       └── validate_project_config_usecase.dart # Validation logic
├── presentation/
│   └── controllers/
│       └── cli_controller.dart          # CLI interaction logic
└── vmgv_cli.dart                        # Main CLI entry point
```

### Architecture Layers

- **Domain Layer**: Contains business entities, use cases, and repository interfaces
- **Data Layer**: Contains repository implementations and data sources
- **Presentation Layer**: Contains controllers for user interaction
- **Core**: Contains dependency injection and shared utilities

## Features

- 🚀 **Interactive Project Creation**: Guided setup with prompts for project configuration
- 🏢 **Organization Name Support**: Automatically sets the `--org` parameter for Flutter projects
- 🔄 **State Management Templates**: Choose from BLoC, Cubit, or Provider with pre-configured templates
- 📦 **Dependency Management**: Automatically adds required dependencies to `pubspec.yaml`
- 🎯 **Ready-to-Run**: Generated projects are immediately runnable with sample code
- 🧪 **Testable**: Clean architecture makes the code highly testable
- 🔧 **Maintainable**: Clear separation of concerns for easy maintenance

## Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd vmgv_cli
```

2. Install dependencies:
```bash
dart pub get
```

3. Make the CLI executable:
```bash
dart compile exe bin/vmgv_cli.dart -o vmgv_cli
```

4. Add to your PATH (optional):
```bash
export PATH="$PATH:$(pwd)"
```

## Usage

### Interactive Mode (Default)

Run the CLI without arguments to start interactive mode:

```bash
dart run bin/vmgv_cli.dart
```

The CLI will prompt you for:
- Project name
- Organization name (e.g., `com.example`)
- State management solution (BLoC, Cubit, Provider, or None)

### Command Line Options

You can also use command line arguments for non-interactive usage:

```bash
dart run bin/vmgv_cli.dart --project-name my_app --org com.example --state-management bloc
```

#### Available Options

- `--project-name, -p`: Project name
- `--org, -o`: Organization name (e.g., com.example)
- `--state-management, -s`: State management solution (bloc, cubit, provider, none)
- `--interactive, -i`: Run in interactive mode (default: true)
- `--help, -h`: Show help message

### Examples

#### Create a basic Flutter project:
```bash
dart run bin/vmgv_cli.dart --project-name my_app --org com.example
```

#### Create a project with BLoC:
```bash
dart run bin/vmgv_cli.dart --project-name my_app --org com.example --state-management bloc
```

#### Create a project with Provider:
```bash
dart run bin/vmgv_cli.dart --project-name my_app --org com.example --state-management provider
```

## State Management Templates

### BLoC Template
- Creates `lib/blocs/` directory
- Generates sample counter BLoC with events and states
- Adds `flutter_bloc` and `equatable` dependencies
- Updates `main.dart` with BLoC integration

### Cubit Template
- Creates `lib/cubits/` directory
- Generates sample counter Cubit with state management
- Adds `flutter_bloc` and `equatable` dependencies
- Updates `main.dart` with Cubit integration

### Provider Template
- Creates `lib/providers/` directory
- Generates sample counter Provider with ChangeNotifier
- Adds `provider` dependency
- Updates `main.dart` with Provider integration

## Project Structure

When you create a project with state management, the CLI generates the following structure:

```
my_app/
├── lib/
│   ├── blocs/          # BLoC files (if using BLoC)
│   ├── cubits/         # Cubit files (if using Cubit)
│   ├── providers/      # Provider files (if using Provider)
│   ├── models/         # Data models
│   ├── repositories/   # Data repositories
│   ├── services/       # Business services
│   ├── utils/          # Utility functions
│   └── main.dart       # Updated with state management integration
├── pubspec.yaml        # Updated with dependencies
└── ...                 # Other Flutter project files
```

## Development

### Running Tests

The project includes comprehensive testing with multiple test types:

#### Unit Tests
```bash
dart test test/vmgv_cli_test.dart
```

#### Flow Tests
```bash
dart test test/flow/cli_flow_test.dart
```

#### End-to-End Tests
```bash
dart test test/e2e/cli_e2e_test.dart
```

#### All Tests
```bash
dart test
```

#### Custom Test Runner
```bash
dart run test/run_tests.dart
```

### Test Coverage

The test suite covers:

- **Unit Tests**: Core functionality, entities, use cases, and validation
- **Flow Tests**: CLI initialization, argument parsing, and error handling
- **Integration Tests**: Complete project creation with all state management types
- **End-to-End Tests**: Full CLI workflow from start to finish

### Test Structure

```
test/
├── vmgv_cli_test.dart          # Unit tests for core functionality
├── flow/
│   └── cli_flow_test.dart      # Flow and integration tests
├── e2e/
│   └── cli_e2e_test.dart       # End-to-end tests
├── test_config.dart            # Test configuration
└── run_tests.dart              # Custom test runner
```

### Code Organization

The codebase follows Clean Architecture principles:

- **Domain Layer**: Contains the core business logic and entities
- **Data Layer**: Handles data operations and external dependencies
- **Presentation Layer**: Manages user interaction and CLI interface
- **Dependency Injection**: Centralized dependency management

### Adding New Features

1. **Domain Layer**: Add new entities, use cases, or repository interfaces
2. **Data Layer**: Implement new data sources or repository implementations
3. **Presentation Layer**: Add new controllers or update existing ones
4. **Dependency Injection**: Wire up new dependencies

## Next Steps

After creating a project:

1. Navigate to the project directory:
```bash
cd my_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Requirements

- Dart SDK 3.7.0 or higher
- Flutter SDK (for creating Flutter projects)
- Git (for version control)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes following Clean Architecture principles
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License.
