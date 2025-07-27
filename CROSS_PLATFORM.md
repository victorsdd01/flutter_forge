# 🌍 Cross-Platform Compatibility Guide

## ✅ Supported Platforms

FlutterForge CLI is designed to work seamlessly across all major operating systems:

- **🪟 Windows** (Windows 10/11)
- **🍎 macOS** (10.15+)
- **🐧 Linux** (Ubuntu 18.04+, Debian 10+, CentOS 7+)

## 📋 System Requirements

### **All Platforms**
- **Dart SDK**: 3.8.0 or higher
- **Flutter SDK**: Latest stable version
- **Git**: For version control (optional but recommended)

### **Platform-Specific Requirements**

#### **Windows**
- Windows 10 or later
- PowerShell 5.0+ or Command Prompt
- Git Bash (optional, for Unix-like experience)

#### **macOS**
- macOS 10.15 (Catalina) or later
- Terminal.app or iTerm2
- Xcode Command Line Tools (for iOS development)

#### **Linux**
- Ubuntu 18.04+, Debian 10+, or CentOS 7+
- Bash shell
- Build essentials (for native compilation)

## 🚀 Installation by Platform

### **Windows Installation**

#### **Option 1: PowerShell (Recommended)**
```powershell
# Install from Git
dart pub global activate --source git https://github.com/yourusername/flutterforge.git

# Or install from local source
git clone https://github.com/yourusername/flutterforge.git
cd flutterforge
dart pub global activate --source path .
```

#### **Option 2: Command Prompt**
```cmd
# Install from Git
dart pub global activate --source git https://github.com/yourusername/flutterforge.git

# Or install from local source
git clone https://github.com/yourusername/flutterforge.git
cd flutterforge
dart pub global activate --source path .
```

#### **Option 3: Installation Scripts**
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

### **macOS Installation**

#### **Option 1: Terminal**
```bash
# Install from Git
dart pub global activate --source git https://github.com/yourusername/flutterforge.git

# Or install from local source
git clone https://github.com/yourusername/flutterforge.git
cd flutterforge
dart pub global activate --source path .
```

#### **Option 2: Installation Script**
```bash
# Using shell script
git clone https://github.com/yourusername/flutterforge.git
cd flutterforge
./install.sh
```

### **Linux Installation**

#### **Option 1: Terminal**
```bash
# Install from Git
dart pub global activate --source git https://github.com/yourusername/flutterforge.git

# Or install from local source
git clone https://github.com/yourusername/flutterforge.git
cd flutterforge
dart pub global activate --source path .
```

#### **Option 2: Installation Script**
```bash
# Using shell script
git clone https://github.com/yourusername/flutterforge.git
cd flutterforge
./install.sh
```

## 🔧 PATH Configuration

### **Windows**
The installation scripts automatically add the CLI to your PATH. If manual configuration is needed:

```cmd
# Add to system PATH
setx PATH "%PATH%;%USERPROFILE%\.pub-cache\bin"

# Or add to user PATH
setx PATH "%PATH%;%USERPROFILE%\.pub-cache\bin" /M
```

### **macOS/Linux**
The installation scripts automatically detect your shell and configure PATH:

```bash
# For Bash
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.bashrc
source ~/.bashrc

# For Zsh
echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc

# For Fish
echo 'set -gx PATH $PATH $HOME/.pub-cache/bin' >> ~/.config/fish/config.fish
source ~/.config/fish/config.fish
```

## 🎯 Usage Commands

### **All Platforms**
```bash
# Basic usage
flutterforge

# With full command
dart pub global run flutterforge

# Show help
flutterforge --help
```

### **Platform-Specific Considerations**

#### **Windows**
- Use PowerShell for best experience with colored output
- Command Prompt works but may not display colors properly
- Git Bash provides Unix-like experience

#### **macOS**
- Terminal.app or iTerm2 work perfectly
- Colors and emojis display correctly
- No special considerations needed

#### **Linux**
- Works with all major terminals (GNOME Terminal, Konsole, etc.)
- Colors and emojis display correctly
- May need to install emoji fonts for better display

## 🔍 Troubleshooting

### **Common Issues**

#### **"flutterforge command not found"**
```bash
# Check if PATH is configured correctly
echo $PATH | grep .pub-cache

# Manually add to PATH
export PATH="$PATH:$HOME/.pub-cache/bin"

# Verify installation
dart pub global list
```

#### **Permission Issues (Linux/macOS)**
```bash
# Make installation script executable
chmod +x install.sh

# Run with proper permissions
sudo ./install.sh  # Only if needed
```

#### **Windows PATH Issues**
```cmd
# Check current PATH
echo %PATH%

# Add manually if needed
setx PATH "%PATH%;%USERPROFILE%\.pub-cache\bin"
```

### **Platform-Specific Issues**

#### **Windows**
- **Issue**: PowerShell execution policy blocks scripts
- **Solution**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

- **Issue**: Command Prompt doesn't show colors
- **Solution**: Use PowerShell or Git Bash instead

#### **macOS**
- **Issue**: Xcode Command Line Tools not installed
- **Solution**: `xcode-select --install`

- **Issue**: Permission denied on installation script
- **Solution**: `chmod +x install.sh`

#### **Linux**
- **Issue**: Missing build essentials
- **Solution**: `sudo apt-get install build-essential` (Ubuntu/Debian)

- **Issue**: Missing emoji fonts
- **Solution**: `sudo apt-get install fonts-noto-color-emoji` (Ubuntu/Debian)

## 🧪 Testing Cross-Platform Compatibility

### **Automated Testing**
The CLI includes cross-platform testing to ensure compatibility:

```bash
# Run all tests
dart test

# Run platform-specific tests
dart test test/cross_platform/
```

### **Manual Testing Checklist**

#### **Windows Testing**
- [ ] PowerShell installation
- [ ] Command Prompt installation
- [ ] PATH configuration
- [ ] Color output display
- [ ] Project generation
- [ ] File path handling

#### **macOS Testing**
- [ ] Terminal installation
- [ ] PATH configuration
- [ ] Color output display
- [ ] Project generation
- [ ] File path handling

#### **Linux Testing**
- [ ] Bash installation
- [ ] Zsh installation
- [ ] Fish installation
- [ ] PATH configuration
- [ ] Color output display
- [ ] Project generation
- [ ] File path handling

## 📦 Generated Project Compatibility

### **Flutter Platform Support**
Generated projects support all Flutter platforms:

- **Mobile**: Android, iOS
- **Web**: Chrome, Firefox, Safari, Edge
- **Desktop**: Windows, macOS, Linux

### **Platform-Specific Features**
- **Windows**: Windows-specific configurations and dependencies
- **macOS**: macOS-specific configurations and dependencies
- **Linux**: Linux-specific configurations and dependencies

## 🔄 Continuous Integration

The CLI is tested on multiple platforms using CI/CD:

- **GitHub Actions**: Windows, macOS, Ubuntu
- **Automated Testing**: Cross-platform compatibility tests
- **Release Validation**: All platforms tested before release

## 📚 Additional Resources

- [Flutter Platform Support](https://flutter.dev/docs/deployment)
- [Dart Cross-Platform Development](https://dart.dev/guides/libraries/create-library-packages)
- [GitHub Actions for Cross-Platform Testing](https://docs.github.com/en/actions/guides/building-and-testing-dart)

---

**FlutterForge CLI is thoroughly tested and guaranteed to work across Windows, macOS, and Linux! 🚀** 