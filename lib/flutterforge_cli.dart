// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:io';
import 'package:args/args.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/version_checker.dart';
import 'presentation/controllers/cli_controller.dart';

/// Main CLI class for Flutter Force
class FlutterForgeCLI {
  static const String _appName = 'flutterforce';
  static const String _description = 'A Flutter CLI tool for creating projects with interactive prompts.';
  static const String _version = '1.0.0';

  late ArgParser _argParser;
  late ArgResults _argResults;
  late CliController _cliController;

  FlutterForgeCLI() {
    _setupArgParser();
    _setupDependencies();
  }

  void _setupArgParser() {
    _argParser = ArgParser()
      ..addFlag(
        'help',
        abbr: 'h',
        help: 'Show this help message',
        negatable: false,
      )
      ..addFlag(
        'version',
        abbr: 'v',
        help: 'Show version information',
        negatable: false,
      )
      ..addFlag(
        'update',
        abbr: 'u',
        help: 'Update FlutterForge CLI to the latest version',
        negatable: false,
      );
  }

  void _setupDependencies() {
    DependencyInjection.initialize();
    _cliController = DependencyInjection.instance.cliController;
  }

  Future<void> run(List<String> arguments) async {
    try {
      _argResults = _argParser.parse(arguments);

      if (_argResults['help']) {
        _printUsage();
        return;
      }

      if (_argResults['version']) {
        _printVersion();
        return;
      }

      if (_argResults['update']) {
        await _updateCLI();
        return;
      }

      // Check for updates when running normally
      await _checkForUpdates();

      // Always run in interactive mode
      _runInteractiveMode();
    } catch (e) {
      print('Error: $e');
      _printUsage();
      exit(1);
    }
  }

  Future<void> _checkForUpdates() async {
    try {
      final isUpdateAvailable = await VersionChecker.isUpdateAvailable(_version);
      if (isUpdateAvailable) {
        final latestVersion = await VersionChecker.getLatestCLIVersion();
        
        // ANSI Color Codes
        const String reset = '\x1B[0m';
        const String bold = '\x1B[1m';
        const String brightYellow = '\x1B[93m';
        const String dim = '\x1B[2m';
        
        print('');
        print('${brightYellow}${bold}🔄 Update Available!${reset}');
        print('${dim}   Current: $_version${reset}');
        print('${dim}   Latest:  $latestVersion${reset}');
        print('${dim}   Run: flutterforge --update${reset}');
        print('');
      }
    } catch (e) {
      // Silently fail - don't interrupt the user experience
    }
  }

  void _runInteractiveMode() {
    _cliController.runInteractiveMode();
  }

  Future<void> _updateCLI() async {
    // ANSI Color Codes
    const String reset = '\x1B[0m';
    const String bold = '\x1B[1m';
    const String brightCyan = '\x1B[96m';
    const String brightGreen = '\x1B[92m';
    const String brightYellow = '\x1B[93m';
    const String brightRed = '\x1B[91m';
    const String red = '\x1B[31m';
    const String dim = '\x1B[2m';
    
    print('');
    print('${brightCyan}${bold}╔══════════════════════════════════════════════════════════════╗${reset}');
    print('${brightCyan}${bold}║${reset}${bold}                    🔄 FLUTTER FORCE UPDATE 🔄                    ${reset}${brightCyan}${bold}║${reset}');
    print('${brightCyan}${bold}╚══════════════════════════════════════════════════════════════╝${reset}');
    print('');
    
    print('${brightGreen}${bold}📦 Current version:${reset} ${brightYellow}$_version${reset}');
    
    // Check for latest version
    final latestVersion = await VersionChecker.getLatestCLIVersion();
    if (latestVersion != null) {
      print('${brightGreen}${bold}📦 Latest version:${reset} ${brightYellow}$latestVersion${reset}');
      
      if (latestVersion == _version) {
        print('');
        print('${brightGreen}${bold}✅ You already have the latest version!${reset}');
        print('');
        return;
      }
    }
    
    print('');
    
    try {
      print('${brightYellow}${bold}🔄 Updating FlutterForge CLI...${reset}');
      print('${dim}This may take a few moments...${reset}');
      print('');
      
      // Execute the update command
      final result = Process.runSync('dart', [
        'pub',
        'global',
        'activate',
        '--source',
        'git',
        'https://github.com/victorsdd01/flutter_forge.git'
      ]);
      
      if (result.exitCode == 0) {
        print('${brightGreen}${bold}✅ FlutterForge CLI updated successfully!${reset}');
        print('');
        print('${brightCyan}${bold}🎉 What\'s new:${reset}');
        print('${dim}   • Latest features and improvements${reset}');
        print('${dim}   • Bug fixes and performance enhancements${reset}');
        print('${dim}   • Updated dependencies and templates${reset}');
        print('');
        print('${brightGreen}${bold}🚀 Ready to create amazing Flutter projects!${reset}');
        print('');
      } else {
        print('${brightRed}${bold}❌ Update failed:${reset}');
        print('${red}${result.stderr}${reset}');
        print('');
        print('${brightYellow}${bold}💡 Manual update:${reset}');
        print('${dim}   dart pub global activate --source git https://github.com/victorsdd01/flutter_forge.git${reset}');
        print('');
      }
    } catch (e) {
      print('${brightRed}${bold}❌ Update failed:${reset} ${red}$e${reset}');
      print('');
      print('${brightYellow}${bold}💡 Manual update:${reset}');
      print('${dim}   dart pub global activate --source git https://github.com/victorsdd01/flutter_forge.git${reset}');
      print('');
    }
  }

  void _printVersion() {
    // ANSI Color Codes
    const String reset = '\x1B[0m';
    const String bold = '\x1B[1m';
    const String brightCyan = '\x1B[96m';
    const String brightMagenta = '\x1B[95m';
    const String brightGreen = '\x1B[92m';
    const String brightYellow = '\x1B[93m';
    const String dim = '\x1B[2m';
    
    print('');
    print('${brightCyan}${bold}╔══════════════════════════════════════════════════════════════╗${reset}');
    print('${brightCyan}${bold}║${reset}${brightMagenta}${bold}                    🚀 FLUTTER FORCE CLI 🚀                    ${reset}${brightCyan}${bold}║${reset}');
    print('${brightCyan}${bold}║${reset}${dim}           The Ultimate Flutter Project Generator           ${reset}${brightCyan}${bold}║${reset}');
    print('${brightCyan}${bold}╚══════════════════════════════════════════════════════════════╝${reset}');
    print('');
    print('${brightGreen}${bold}📦 Version:${reset} ${brightYellow}$_version${reset}');
    print('${brightGreen}${bold}📝 Description:${reset} ${dim}$_description${reset}');
    print('');
    print('${brightCyan}${bold}🔗 Repository:${reset} ${dim}https://github.com/victorsdd01/flutter_forge${reset}');
    print('${brightCyan}${bold}🔄 To update:${reset} ${dim}dart pub global activate --source git https://github.com/victorsdd01/flutter_forge.git${reset}');
    print('');
    print('${brightMagenta}${bold}✨ Happy coding with Flutter Force! ✨${reset}');
    print('');
  }

  void _printUsage() {
    // ANSI Color Codes
    const String reset = '\x1B[0m';
    const String bold = '\x1B[1m';
    const String brightCyan = '\x1B[96m';
    const String brightGreen = '\x1B[92m';
    const String dim = '\x1B[2m';
    
    print('');
    print('${brightCyan}${bold}╔══════════════════════════════════════════════════════════════╗${reset}');
    print('${brightCyan}${bold}║${reset}${bold}                    🚀 FLUTTER FORCE CLI 🚀                    ${reset}${brightCyan}${bold}║${reset}');
    print('${brightCyan}${bold}╚══════════════════════════════════════════════════════════════╝${reset}');
    print('');
    print('${brightGreen}${bold}📝 Description:${reset} ${dim}$_description${reset}');
    print('');
    print('${brightGreen}${bold}🚀 Usage:${reset}');
    print('${dim}   $_appName${reset} ${brightCyan}${bold}# Start interactive project creation${reset}');
    print('${dim}   $_appName --help${reset} ${brightCyan}${bold}# Show this help message${reset}');
    print('${dim}   $_appName --version${reset} ${brightCyan}${bold}# Show version information${reset}');
    print('${dim}   $_appName --update${reset} ${brightCyan}${bold}# Update to latest version${reset}');
    print('');
    print('${brightGreen}${bold}✨ Features:${reset}');
    print('${dim}   • Interactive project configuration${reset}');
    print('${dim}   • Multiple platform support (Mobile, Web, Desktop)${reset}');
    print('${dim}   • State management options (BLoC, Cubit, Provider)${reset}');
    print('${dim}   • Clean Architecture integration${reset}');
    print('${dim}   • Go Router navigation${reset}');
    print('${dim}   • Freezed code generation${reset}');
    print('${dim}   • Custom linter rules${reset}');
    print('${dim}   • Internationalization support${reset}');
    print('');
    print('${brightCyan}${bold}🔗 Repository:${reset} ${dim}https://github.com/victorsdd01/flutter_forge${reset}');
    print('');
  }
}
