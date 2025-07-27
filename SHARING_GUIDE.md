# 🚀 FlutterForge CLI - Sharing Guide

## 📋 How to Share Your CLI Tool

### 1. **GitHub Repository Setup**

First, create a GitHub repository and push your code:

```bash
# Initialize git repository
git init
git add .
git commit -m "Initial release: FlutterForge CLI v1.0.0"

# Create GitHub repository and push
git remote add origin https://github.com/yourusername/flutterforge.git
git branch -M main
git push -u origin main
```

### 2. **Update Repository URLs**

Replace `yourusername` with your actual GitHub username in these files:
- `pubspec.yaml` (homepage, repository, issue_tracker)
- `README.md` (all GitHub links)
- `USAGE.md` (all GitHub links)
- `install.sh` (GitHub link)

### 3. **Publish to Pub.dev (Optional)**

To make your CLI available on pub.dev:

```bash
# Test the package
dart pub publish --dry-run

# Publish the package
dart pub publish
```

## 🎯 Installation Commands for Users

### **Cross-Platform Support** 🌍
FlutterForge CLI works on **Windows**, **macOS**, and **Linux**!

### **Option 1: Install from Git (Recommended)**
```bash
# All platforms
dart pub global activate --source git https://github.com/yourusername/flutterforge.git
```

### **Option 2: Install from Local Source**
```bash
git clone https://github.com/yourusername/flutterforge.git
cd flutterforge
dart pub global activate --source path .
```

### **Option 3: Use Installation Scripts**

#### **Windows**
```cmd
# Using batch script
git clone https://github.com/yourusername/flutterforge.git
cd flutterforge
install.bat

# Using PowerShell script
git clone https://github.com/yourusername/flutterforge.git
cd flutterforge
powershell -ExecutionPolicy Bypass -File install.ps1
```

#### **macOS/Linux**
```bash
# Using shell script
git clone https://github.com/yourusername/flutterforge.git
cd flutterforge
./install.sh
```

### **Option 4: Install from Pub.dev (When Published)**
```bash
dart pub global activate flutterforge
```

## 🚀 Usage Commands for Users

### **Basic Usage**
```bash
# Create a new Flutter project interactively
flutterforge

# Or with the full command
dart pub global run flutterforge
```

### **Command Line Options**
```bash
# Show help
flutterforge --help

# Create project with specific name
flutterforge create my_app

# Run in non-interactive mode (future feature)
flutterforge create my_app --non-interactive
```

## 📦 What Users Get

When users run `flutterforge`, they get:

1. **Interactive Prompts** for project configuration
2. **Clean Architecture** structure
3. **State Management** setup (BLoC, Cubit, Provider)
4. **Freezed** code generation (if selected)
5. **Go Router** navigation
6. **Internationalization** with ARB files
7. **Custom Linting** rules
8. **Latest Dependencies** automatically added
9. **Sample Code** for all patterns
10. **Ready-to-Run** project

## 🔧 Post-Generation Commands for Users

### **For All Projects**
```bash
cd my_app
flutter pub get
flutter analyze
flutter run
```

### **For Freezed Projects**
```bash
cd my_app
dart run build_runner build -d
flutter pub get
flutter run
```

## 📋 Example User Workflow

```bash
# 1. Install the CLI
dart pub global activate --source git https://github.com/yourusername/flutterforge.git

# 2. Create a project
flutterforge

# 3. Follow interactive prompts:
#    Project name: my_awesome_app
#    Organization: com.example
#    Platforms: Mobile (Android & iOS)
#    State Management: BLoC
#    Freezed: Yes
#    Go Router: Yes
#    Clean Architecture: Yes
#    Linter Rules: Yes

# 4. Navigate to project
cd my_awesome_app

# 5. Get dependencies
flutter pub get

# 6. Generate Freezed files (if enabled)
dart run build_runner build -d

# 7. Run the app
flutter run
```

## 🎨 Generated Project Structure

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

### **State Management**
- `flutter_bloc: ^9.1.1`
- `hydrated_bloc: ^10.1.1`
- `replay_bloc: ^0.3.0`
- `bloc_concurrency: ^0.3.0`
- `dartz: ^0.10.1`
- `equatable: ^2.0.7`

### **Navigation**
- `go_router: ^16.0.0`

### **Dependency Injection**
- `get_it: ^8.0.3`

### **Code Generation (if Freezed enabled)**
- `json_annotation: ^4.9.0`
- `freezed_annotation: ^2.4.4`
- `freezed: ^2.5.7`
- `json_serializable: ^6.8.0`
- `build_runner: ^2.4.13`

### **Internationalization**
- `flutter_localizations: sdk: flutter`
- `intl: any`
- `intl_utils: ^2.8.10`

### **Utilities**
- `path_provider: ^2.1.5`

## 🚀 Marketing Your CLI

### **GitHub Repository Features**
- ✅ Comprehensive README.md
- ✅ Usage examples
- ✅ Installation instructions
- ✅ Feature list
- ✅ Screenshots/demos
- ✅ Contributing guidelines
- ✅ License information

### **Social Media Promotion**
- Share on Flutter/Dart communities
- Post on Reddit (r/FlutterDev)
- Share on Twitter/X with relevant hashtags
- Create YouTube tutorials
- Write blog posts

### **Community Engagement**
- Respond to issues promptly
- Accept pull requests
- Provide support in discussions
- Create examples and tutorials
- Maintain regular updates

## 🎉 Success Metrics

Track these metrics to measure success:
- GitHub stars
- Downloads from pub.dev
- Issues and feature requests
- Community feedback
- Usage in real projects
- Contributions from the community

---

**Your FlutterForge CLI is now ready to share with the Flutter community! 🚀** 