#!/bin/bash

# FlutterForge CLI Installation Script
# This script installs the FlutterForge CLI tool globally

set -e

echo "🚀 Installing FlutterForge CLI..."

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "❌ Dart is not installed. Please install Dart first:"
    echo "   https://dart.dev/get-dart"
    exit 1
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed. Please install Flutter first:"
    echo "   https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Install the CLI globally
echo "📦 Installing FlutterForge CLI..."
dart pub global activate --source path .

# Add to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.pub-cache/bin:"* ]]; then
    echo "🔧 Adding to PATH..."
    
    # Detect shell and add to appropriate config file
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.zshrc
        echo "Please restart your terminal or run: source ~/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        echo 'export PATH="$PATH:$HOME/.pub-cache/bin"' >> ~/.bashrc
        echo "Please restart your terminal or run: source ~/.bashrc"
    elif [[ "$SHELL" == *"fish"* ]]; then
        echo 'set -gx PATH $PATH $HOME/.pub-cache/bin' >> ~/.config/fish/config.fish
        echo "Please restart your terminal or run: source ~/.config/fish/config.fish"
    else
        echo "Please add $HOME/.pub-cache/bin to your PATH manually"
    fi
fi

echo "✅ FlutterForge CLI installed successfully!"
echo ""
echo "🎯 Usage:"
echo "  flutterforge"
echo ""
echo "📚 For more information, visit:"
echo "  https://github.com/yourusername/flutterforge"
echo ""
echo "🚀 Happy coding with Flutter!" 