# Changelog

All notable changes to FlutterForge CLI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Version management system with automatic bumping
- GitHub Actions workflow for automated releases
- CHANGELOG.md for tracking version history

## [1.10.0] - 2025-07-28

### Added
- 🎯 **Improved Platform Selection Flow** - No more tedious individual platform questions!
- ⚡ **Quick Selection Options** - Choose from preset configurations or use quick commands
- 🚀 **Better User Experience** - Streamlined platform selection with 8 preset options
- 🎨 **Enhanced CLI Interface** - More intuitive and user-friendly platform selection

### Changed
- 🔄 **Platform Selection Redesign** - Replaced individual platform questions with smart preset options
- 📱 **Mobile Platform Handling** - Android and iOS are now grouped as "Mobile" platform
- 💻 **Desktop Platform Handling** - Windows, macOS, and Linux are now grouped as "Desktop" platform
- 🌐 **Web Platform** - Standalone web platform option
- ⚡ **Quick Commands** - Added "mobile", "desktop", "all", "none" quick selection commands

### Features
- **8 Preset Options**: Mobile Only, Web Only, Desktop Only, Mobile + Web, Mobile + Desktop, Web + Desktop, All Platforms, Custom Selection
- **Quick Commands**: Type "mobile", "desktop", "all", or "none" for instant selection
- **Fallback to Individual**: Still available for users who want granular control
- **Smart Defaults**: Defaults to Mobile (Android & iOS) if no selection is made

## [1.1.0] - 2025-07-28

### Added
- ✨ Beautiful animated progress bar for CLI updates
- 🎊 Completion celebration animation
- 🔄 Enhanced update system with version checking
- 🎨 Improved CLI styling with colors and emojis
- 📊 Step-by-step progress visualization
- 🎯 Spinning animations during updates

### Changed
- 🎨 Enhanced CLI appearance with professional styling
- 📋 Improved help and version display
- 🚀 Better user experience with visual feedback

### Fixed
- 🔧 Resolved dependency injection issues
- 🐛 Fixed CLI controller method signatures
- 🔧 Corrected import paths and class references

## [1.0.0] - 2024-12-27

### Added
- 🚀 Initial FlutterForge CLI release
- 📝 Interactive project configuration
- 🌍 Multi-platform support (Mobile, Web, Desktop)
- 🎯 State management options (BLoC, Cubit, Provider)
- 🏛️ Clean Architecture integration
- 🛣️ Go Router navigation support
- ❄️ Freezed code generation
- 🔍 Custom linter rules
- 🌐 Internationalization support
- 📦 Dependency injection with GetIt
- 🔄 Update and uninstall functionality
- 📚 Comprehensive documentation
- 🎨 Beautiful CLI interface with colors and styling

### Features
- Interactive prompts for project setup
- Platform selection (Android, iOS, Web, Windows, macOS, Linux)
- State management configuration
- Clean Architecture structure generation
- Go Router setup with sample pages
- Freezed integration for immutable data classes
- Custom linter rules for code quality
- Internationalization with ARB files
- Cross-platform installation scripts
- Version checking and update system
- Professional CLI styling and animations

---

## Version Bumping Guidelines

### Patch (1.0.0 → 1.0.1)
- Bug fixes
- Minor improvements
- Documentation updates
- Performance optimizations

### Minor (1.0.0 → 1.1.0)
- New features
- Enhanced functionality
- UI/UX improvements
- New configuration options

### Major (1.0.0 → 2.0.0)
- Breaking changes
- Major architectural changes
- Significant feature additions
- Incompatible API changes

## Automatic Version Bumping

This project uses GitHub Actions to automatically bump versions when PRs are merged to main:

- **Default**: Patch bump (1.0.0 → 1.0.1)
- **[MINOR] in PR title**: Minor bump (1.0.0 → 1.1.0)
- **[MAJOR] in PR title**: Major bump (1.0.0 → 2.0.0)
- **Labels**: Use `minor` or `major` labels for automatic detection

## Manual Version Management

Use the version manager script:

```bash
# Show current version
dart run scripts/version_manager.dart show

# Bump versions
dart run scripts/version_manager.dart patch   # 1.0.0 → 1.0.1
dart run scripts/version_manager.dart minor   # 1.0.0 → 1.1.0
dart run scripts/version_manager.dart major   # 1.0.0 → 2.0.0
```
