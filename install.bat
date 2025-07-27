@echo off
REM FlutterForge CLI Installation Script for Windows
REM This script installs the FlutterForge CLI tool globally

echo 🚀 Installing FlutterForge CLI...

REM Check if Dart is installed
where dart >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Dart is not installed. Please install Dart first:
    echo    https://dart.dev/get-dart
    pause
    exit /b 1
)

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Flutter is not installed. Please install Flutter first:
    echo    https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

REM Install the CLI globally
echo 📦 Installing FlutterForge CLI...
dart pub global activate --source path .

REM Add to PATH if not already there
echo %PATH% | findstr /C:"%USERPROFILE%\.pub-cache\bin" >nul
if %errorlevel% neq 0 (
    echo 🔧 Adding to PATH...
    setx PATH "%PATH%;%USERPROFILE%\.pub-cache\bin"
    echo Please restart your terminal or command prompt
)

echo ✅ FlutterForge CLI installed successfully!
echo.
echo 🎯 Usage:
echo   flutterforge
echo.
echo 📚 For more information, visit:
echo   https://github.com/victorsdd01/flutter_forge
echo.
echo 🚀 Happy coding with Flutter!
pause 