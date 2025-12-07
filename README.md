# 🚀 FlutterForge CLI

A powerful Flutter CLI tool for creating projects with interactive prompts, supporting Clean Architecture, BLoC, Freezed, Go Router, and internationalization.

## ✨ Features

- 🎯 **Interactive Project Creation** - Guided setup with prompts
- 🏗️ **Clean Architecture** - Domain, Data, and Presentation layers
- 🔄 **State Management** - BLoC, Cubit, Provider, or None
- ❄️ **Freezed Support** - Immutable data classes and code generation
- 🗺️ **Go Router** - Declarative routing with deep linking
- 🌍 **Internationalization** - Multi-language support with ARB files
- 📱 **Multi-Platform** - Mobile, Web, and Desktop support
- 🔍 **Custom Linting** - Code quality and style enforcement
- 💉 **Dependency Injection** - GetIt-based DI setup
- 📦 **Latest Dependencies** - Always up-to-date package versions

## 🛠️ Installation

### **Cross-Platform Support**
FlutterForge CLI works on **Windows**, **macOS**, and **Linux**! 🪟🍎🐧

### Option 1: Install from Git (Recommended)

```bash
# All platforms
dart pub global activate --source git https://github.com/victorsdd01/flutter_forge.git
```

### Option 2: Install from Local Source

```bash
# Clone the repository
git clone https://github.com/victorsdd01/flutter_forge.git
cd flutter_forge

# Install globally
dart pub global activate --source path .
```

### Option 3: Use Installation Scripts (Recommended)

#### **Windows**
```cmd
# Using batch script
git clone https://github.com/victorsdd01/flutter_forge.git
cd flutter_forge
install.bat

# Using PowerShell script
git clone https://github.com/victorsdd01/flutter_forge.git
cd flutter_forge
powershell -ExecutionPolicy Bypass -File install.ps1
```

#### **macOS/Linux**
```bash
# Using shell script (automatically configures PATH)
git clone https://github.com/victorsdd01/flutter_forge.git
cd flutter_forge
./install.sh

# Verify installation
./check_installation.sh
```

### Option 4: Install from Pub.dev (When Published)

```bash
dart pub global activate flutterforge
```

## 🚀 Usage

### Basic Usage

```bash
# Create a new Flutter project interactively
flutterforge

# Or with the full command
dart pub global run flutterforge
```

### Command Line Options

```bash
# Show help
flutterforge --help

# Create project with specific name
flutterforge create my_app

# Run in non-interactive mode (future feature)
flutterforge create my_app --non-interactive
```

## 📋 Interactive Prompts

The CLI will guide you through the following options:

1. **Project Details**
   - Project name
   - Organization name

2. **Platform Selection**
   - Mobile (Android/iOS)
   - Web
   - Desktop (Windows/macOS/Linux)
   - Custom selection

3. **State Management**
   - BLoC (Business Logic Component)
   - Cubit (Simplified BLoC)
   - Provider
   - None

4. **Freezed Configuration** (if BLoC selected)
   - Enable Freezed for immutable data classes
   - Code generation setup

5. **Navigation**
   - Go Router integration
   - Sample pages and routes

6. **Architecture**
   - Clean Architecture structure
   - Domain, Data, Presentation layers

7. **Code Quality**
   - Custom linter rules
   - Analysis options

8. **Internationalization**
   - Multi-language support
   - ARB files setup

## 🏗️ Generated Project Structure

```
my_app/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── utils/
│   │   └── di/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   ├── data/
│   │   ├── datasources/
│   │   ├── repositories/
│   │   └── models/
│   ├── presentation/
│   │   ├── pages/
│   │   ├── widgets/
│   │   └── controllers/
│   ├── application/
│   │   ├── l10n/
│   │   └── generated/
│   └── main.dart
├── pubspec.yaml
├── analysis_options.yaml
├── build.yaml (if Freezed enabled)
└── README.md
```

## 📦 Dependencies Included

### State Management
- `flutter_bloc: ^9.1.1`
- `hydrated_bloc: ^10.1.1`
- `replay_bloc: ^0.3.0`
- `bloc_concurrency: ^0.3.0`
- `dartz: ^0.10.1`
- `equatable: ^2.0.7`

### Navigation
- `go_router: ^16.0.0`

### Dependency Injection
- `get_it: ^8.0.3`

### Code Generation (if Freezed enabled)
- `json_annotation: ^4.9.0`
- `freezed_annotation: ^2.4.4`
- `freezed: ^2.5.7`
- `json_serializable: ^6.8.0`
- `build_runner: ^2.4.13`

### Internationalization
- `flutter_localizations: sdk: flutter`
- `intl: any`
- `intl_utils: ^2.8.10`

### Utilities
- `path_provider: ^2.1.5`

## 🔧 Post-Generation Steps

### For Freezed Projects
```bash
cd my_app
dart run build_runner build -d
```

### For All Projects
```bash
cd my_app
flutter pub get
flutter analyze
flutter run
```

## 🎯 Example Usage

```bash
# Start the CLI
flutterforge

# Follow the interactive prompts:
# 1. Project name: my_awesome_app
# 2. Organization: com.example
# 3. Platforms: Mobile (Android & iOS)
# 4. State Management: BLoC
# 5. Freezed: Yes
# 6. Go Router: Yes
# 7. Clean Architecture: Yes
# 8. Linter Rules: Yes

# Your project will be created with all configurations!
```

## 🚀 Quick Start

```bash
# Install the CLI
dart pub global activate --source git https://github.com/victorsdd01/flutter_forge.git

# Create your first project
flutterforge

# Navigate to your project
cd my_app

# Get dependencies
flutter pub get

# Run the app
flutter run
```

## 🔄 Updating FlutterForge CLI

### **Check Current Version:**
```bash
# Using direct command (recommended)
flutterforge --version

# Or check the installed version
dart pub global list | grep flutterforge
```

### **Update to Latest Version:**
```bash
# Update to latest version (recommended)
flutterforge -u
# or
flutterforge --update

# Manual update from Git
dart pub global activate --source git https://github.com/victorsdd01/flutter_forge.git

# Or if you want a specific version
dart pub global activate --source git https://github.com/victorsdd01/flutter_forge.git --git-ref v1.1.0
```

### **Update from Local Source:**
```bash
# If you have the repository cloned locally
cd flutter_forge
git pull origin main
dart pub global activate --source path .

# Or use the CLI update command
flutterforge -u
```

## 🗑️ Uninstalling FlutterForge CLI

### **Manual Uninstall:**
```bash
# Deactivate the package
dart pub global deactivate flutterforge

# Remove from PATH manually if needed
# Edit your shell config file (~/.bashrc, ~/.zshrc, etc.)
```

### **Using Uninstall Scripts:**

#### **Windows:**
```cmd
# Using batch script
uninstall.bat

# Using PowerShell script
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

#### **macOS/Linux:**
```bash
# Using shell script
./uninstall.sh
```

### **Verify Uninstall:**
```bash
# Check if CLI is still available
flutterforge --version

# Should show "command not found" or similar error
```

## 🔧 Troubleshooting

### **Command Not Found After Installation**

If `flutterforge` command is not found after installation:

1. **Restart your terminal** - The PATH changes take effect in new terminal sessions
2. **Check PATH manually:**
   ```bash
   echo $PATH | grep pub-cache
   ```
3. **Add to PATH manually:**
   ```bash
   # For bash/zsh
   export PATH="$PATH:$HOME/.pub-cache/bin"
   
   # Add to your shell config file (~/.bashrc, ~/.zshrc)
   echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
   ```
4. **Verify installation:**
   ```bash
   ./check_installation.sh
   ```

### **Dart Version Compatibility**

If you get version compatibility errors:

1. **Check your Dart version:**
   ```bash
   dart --version
   ```
2. **Update Dart if needed:**
   ```bash
   # Using FVM (recommended)
   fvm install stable
   fvm use stable
   
   # Or download from dart.dev
   ```

### **Permission Issues**

If you get permission errors:

1. **Make scripts executable:**
   ```bash
   chmod +x install.sh
   chmod +x check_installation.sh
   ```
2. **Check file permissions:**
   ```bash
   ls -la install.sh
   ```

### **Still Having Issues?**

1. **Check the installation logs**
2. **Try manual installation:**
   ```bash
   dart pub global activate --source path .
   ```
3. **Verify PATH configuration**
4. **Open an issue on GitHub** with your error details

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- BLoC library for state management
- Freezed for code generation
- Go Router for navigation
- All contributors and users

---

**Made with ❤️ for the Flutter community**
