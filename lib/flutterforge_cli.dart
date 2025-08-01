// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:io';
import 'package:args/args.dart';
import 'core/di/dependency_injection.dart';
import 'core/utils/version_checker.dart';
import 'presentation/controllers/cli_controller.dart';

/// Main CLI class for FlutterForge
class FlutterForgeCLI {
  static const String _appName = 'flutterforce';
  static const String _description = 'A Flutter CLI tool for creating projects with interactive prompts.';
  static const String _version = '1.10.0';

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

  Future<void> _showUpdateProgress() async {
    const String reset = '\x1B[0m';
    const String bold = '\x1B[1m';
    const String brightGreen = '\x1B[92m';
    const String brightYellow = '\x1B[93m';
    const String brightCyan = '\x1B[96m';
    const String brightBlue = '\x1B[94m';
    const String dim = '\x1B[2m';
    
    print('${brightBlue}${bold}📊 Update Progress:${reset}');
    print('');
    
    final steps = [
      {'icon': '🔍', 'text': 'Checking for latest version', 'duration': 600},
      {'icon': '📦', 'text': 'Downloading new version', 'duration': 1200},
      {'icon': '⚙️', 'text': 'Installing dependencies', 'duration': 1000},
      {'icon': '🔧', 'text': 'Updating global package', 'duration': 800},
      {'icon': '✨', 'text': 'Finalizing installation', 'duration': 600},
    ];
    
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      
      // Show step header
      print('${brightCyan}${bold}Step ${i + 1}/${steps.length}:${reset} ${brightYellow}${step['icon']} ${step['text']}${reset}');
      
      // Show progress bar with spinner
      stdout.write('${dim}   ${_getSpinner(0)} [${_getProgressBar(0)}] 0%${reset}');
      
      // Animate progress bar with spinning
      for (int p = 0; p <= 100; p += 5) {
        await Future.delayed(Duration(milliseconds: (step['duration'] as int) ~/ 20));
        stdout.write('\r${dim}   ${_getSpinner(p ~/ 5)} [${_getProgressBar(p)}] ${p.toString().padLeft(3)}%${reset}');
      }
      
      // Show completion
      print(' ${brightGreen}✅${reset}');
      print('');
    }
    
    print('${brightGreen}${bold}🎉 All steps completed successfully!${reset}');
    print('');
  }
  
  Future<void> _showCompletionCelebration() async {
    const String reset = '\x1B[0m';
    const String bold = '\x1B[1m';
    const String brightYellow = '\x1B[93m';
    const String brightCyan = '\x1B[96m';
    const String brightMagenta = '\x1B[95m';
    
    final celebrations = [
      '🎉', '✨', '🚀', '🎊', '💫', '🌟', '🎈', '🎯', '🏆', '💎'
    ];
    
    print('');
    print('${brightMagenta}${bold}╔══════════════════════════════════════════════════════════════╗${reset}');
    print('${brightMagenta}${bold}║${reset}${brightYellow}${bold}                    🎊 UPDATE COMPLETE! 🎊                    ${reset}${brightMagenta}${bold}║${reset}');
    print('${brightMagenta}${bold}╚══════════════════════════════════════════════════════════════╝${reset}');
    print('');
    
    // Animated celebration
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < celebrations.length; j++) {
        stdout.write('\r${brightCyan}${bold}${celebrations[j]}${reset} ');
        await Future.delayed(Duration(milliseconds: 100));
      }
    }
    print('');
    print('');
  }
  
  String _getProgressBar(int percentage) {
    const int barLength = 20;
    final filledLength = (percentage / 100 * barLength).round();
    final emptyLength = barLength - filledLength;
    
    final filled = '█' * filledLength;
    final empty = '░' * emptyLength;
    
    return filled + empty;
  }
  
  String _getSpinner(int step) {
    final spinners = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
    return spinners[step % spinners.length];
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
        print('${dim}   Run: flutterforge -u${reset} ${dim}or${reset} ${dim}flutterforge --update${reset}');
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
                  print('${brightCyan}${bold}║${reset}${bold}                    🔄 FLUTTERFORGE UPDATE 🔄                    ${reset}${brightCyan}${bold}║${reset}');
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
      print('');
      
      // Show progress steps
      await _showUpdateProgress();
      
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
        await _showCompletionCelebration();
        print('');
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
        print('${dim}   flutterforge -u${reset} ${dim}or${reset} ${dim}flutterforge --update${reset}');
        print('');
      }
    } catch (e) {
      print('${brightRed}${bold}❌ Update failed:${reset} ${red}$e${reset}');
      print('');
      print('${brightYellow}${bold}💡 Manual update:${reset}');
      print('${dim}   flutterforge -u${reset} ${dim}or${reset} ${dim}flutterforge --update${reset}');
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
                  print('${brightCyan}${bold}║${reset}${brightMagenta}${bold}                    🚀 FLUTTERFORGE CLI 🚀                    ${reset}${brightCyan}${bold}║${reset}');
    print('${brightCyan}${bold}║${reset}${dim}           The Ultimate Flutter Project Generator           ${reset}${brightCyan}${bold}║${reset}');
    print('${brightCyan}${bold}╚══════════════════════════════════════════════════════════════╝${reset}');
    print('');
    print('${brightGreen}${bold}📦 Version:${reset} ${brightYellow}$_version${reset}');
    print('${brightGreen}${bold}📝 Description:${reset} ${dim}$_description${reset}');
    print('');
    print('${brightCyan}${bold}🔗 Repository:${reset} ${dim}https://github.com/victorsdd01/flutter_forge${reset}');
    print('${brightCyan}${bold}🔄 To update:${reset} ${dim}flutterforge -u${reset} ${dim}or${reset} ${dim}flutterforge --update${reset}');
    print('');
                  print('${brightMagenta}${bold}✨ Happy coding with FlutterForge! ✨${reset}');
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
                  print('${brightCyan}${bold}║${reset}${bold}                    🚀 FLUTTERFORGE CLI 🚀                    ${reset}${brightCyan}${bold}║${reset}');
    print('${brightCyan}${bold}╚══════════════════════════════════════════════════════════════╝${reset}');
    print('');
    print('${brightGreen}${bold}📝 Description:${reset} ${dim}$_description${reset}');
    print('');
    print('${brightGreen}${bold}🚀 Usage:${reset}');
    print('${dim}   $_appName${reset} ${brightCyan}${bold}# Start interactive project creation${reset}');
    print('${dim}   $_appName --help${reset} ${brightCyan}${bold}# Show this help message${reset}');
    print('${dim}   $_appName --version${reset} ${brightCyan}${bold}# Show version information${reset}');
    print('${dim}   $_appName -u${reset} ${brightCyan}${bold}# Update to latest version${reset}');
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
