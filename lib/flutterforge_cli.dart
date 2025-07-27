import 'dart:io';
import 'package:args/args.dart';
import 'core/di/dependency_injection.dart';
import 'domain/entities/project_config.dart';
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
      );
  }

  void _setupDependencies() {
    DependencyInjection.initialize();
    _cliController = DependencyInjection.instance.cliController;
  }

  void run(List<String> arguments) {
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

      // Always run in interactive mode
      _runInteractiveMode();
    } catch (e) {
      print('Error: $e');
      _printUsage();
      exit(1);
    }
  }

  void _runInteractiveMode() {
    _cliController.runInteractiveMode();
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
