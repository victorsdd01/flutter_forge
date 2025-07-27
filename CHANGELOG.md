# Changelog

All notable changes to the FlutterForge CLI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- 🎉 **Initial Release** - FlutterForge CLI tool
- 🎯 **Interactive Project Creation** - Guided setup with prompts
- 🏗️ **Clean Architecture Support** - Domain, Data, and Presentation layers
- 🔄 **State Management Options** - BLoC, Cubit, Provider, or None
- ❄️ **Freezed Integration** - Immutable data classes and code generation
- 🗺️ **Go Router Support** - Declarative routing with deep linking
- 🌍 **Internationalization** - Multi-language support with ARB files
- 📱 **Multi-Platform Support** - Mobile, Web, and Desktop platforms
- 🔍 **Custom Linting** - Code quality and style enforcement
- 💉 **Dependency Injection** - GetIt-based DI setup
- 📦 **Latest Dependencies** - Always up-to-date package versions
- 🎨 **Beautiful ASCII Art** - FlutterForge logo display
- 📋 **Configuration Summary** - Review before project creation
- 🔧 **Post-Generation Instructions** - Clear next steps for users

### Features
- Interactive prompts for project configuration
- Platform selection (Mobile, Web, Desktop)
- State management selection with dependencies
- Freezed code generation setup
- Go Router integration with sample pages
- Clean Architecture structure generation
- Custom linter rules configuration
- Internationalization setup with ARB files
- Dependency injection with GetIt
- Barrel files for each layer
- Sample implementations for all patterns

### Dependencies Included
- **State Management**: flutter_bloc, hydrated_bloc, replay_bloc, bloc_concurrency, dartz, equatable
- **Navigation**: go_router
- **DI**: get_it
- **Code Generation**: json_annotation, freezed_annotation, freezed, json_serializable, build_runner
- **Internationalization**: flutter_localizations, intl, intl_utils
- **Utilities**: path_provider

### Technical Details
- Clean Architecture implementation
- Proper dependency management
- Error handling and validation
- Cross-platform compatibility
- Comprehensive testing structure
- Documentation and examples

---

## [Unreleased]

### Planned Features
- Non-interactive mode support
- Template customization
- Plugin system
- Advanced configuration options
- Performance optimizations
- Additional state management patterns
- More platform-specific configurations
