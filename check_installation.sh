#!/bin/bash

# FlutterForge CLI Installation Check Script

echo "🔍 Checking FlutterForge CLI installation..."

# Check if flutterforge command is available
if command -v flutterforge &> /dev/null; then
    echo "✅ flutterforge command found at: $(which flutterforge)"
    
    # Check version
    echo "📦 Version information:"
    flutterforge --version
    
    # Check if .pub-cache/bin is in PATH
    if [[ ":$PATH:" == *":$HOME/.pub-cache/bin:"* ]]; then
        echo "✅ $HOME/.pub-cache/bin is in PATH"
    else
        echo "❌ $HOME/.pub-cache/bin is NOT in PATH"
        echo "💡 Add this to your shell config file:"
        echo "   export PATH=\"\$PATH:\$HOME/.pub-cache/bin\""
    fi
    
    # Check if the executable file exists
    if [ -f "$HOME/.pub-cache/bin/flutterforge" ]; then
        echo "✅ Executable file exists"
    else
        echo "❌ Executable file not found"
    fi
    
else
    echo "❌ flutterforge command not found"
    echo ""
    echo "🔧 Troubleshooting steps:"
    echo "1. Run the installation script: ./install.sh"
    echo "2. Restart your terminal"
    echo "3. Or manually add to PATH: export PATH=\"\$PATH:\$HOME/.pub-cache/bin\""
    echo "4. Check if Dart is installed: dart --version"
    echo ""
    exit 1
fi

echo ""
echo "🎉 FlutterForge CLI is ready to use!" 