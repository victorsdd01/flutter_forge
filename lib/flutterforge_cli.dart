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
  late CLIController _cliController;

  FlutterForgeCLI() {
    _setupArgParser();
    _setupDependencies();
  }

  void _setupArgParser() {
    _argParser = ArgParser()
      ..addOption(
        'org',
        abbr: 'o',
        help: 'Organization name for the Flutter project',
        defaultsTo: '',
      )
      ..addOption(
        'state-management',
        abbr: 's',
        help: 'State management solution (bloc, cubit, provider)',
        allowed: ['bloc', 'cubit', 'provider', 'none'],
        defaultsTo: 'none',
      )
      ..addOption(
        'project-name',
        abbr: 'p',
        help: 'Project name',
        defaultsTo: '',
      )
      ..addFlag(
        'interactive',
        abbr: 'i',
        help: 'Run in interactive mode',
        defaultsTo: true,
      )
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

      if (_argResults['interactive']) {
        _runInteractiveMode();
      } else {
        _runNonInteractiveMode();
      }
    } catch (e) {
      print('Error: $e');
      _printUsage();
      exit(1);
    }
  }

  void _runInteractiveMode() {
    _cliController.runInteractiveMode();
  }

  void _runNonInteractiveMode() {
    final projectName = _argResults['project-name'];
    final orgName = _argResults['org'];
    final stateManagementStr = _argResults['state-management'];

    if (projectName.isEmpty || orgName.isEmpty) {
      print('Error: Project name and organization name are required in non-interactive mode.');
      print('Use --help for more information.');
      exit(1);
    }

    final stateManagement = _parseStateManagement(stateManagementStr);
    
    final config = ProjectConfig(
      projectName: projectName,
      organizationName: orgName,
      stateManagement: stateManagement,
    );

    _cliController.runNonInteractiveMode(config);
  }

  StateManagementType _parseStateManagement(String value) {
    switch (value) {
      case 'bloc':
        return StateManagementType.bloc;
      case 'cubit':
        return StateManagementType.cubit;
      case 'provider':
        return StateManagementType.provider;
      case 'none':
      default:
        return StateManagementType.none;
    }
  }

  void _printVersion() {
    print('$_appName version $_version');
    print(_description);
    print('');
    print('Repository: https://github.com/victorsdd01/flutter_forge');
    print('To update: dart pub global activate --source git https://github.com/victorsdd01/flutter_forge.git');
  }

  void _printUsage() {
    print('$_appName - $_description');
    print('');
    print('Usage: $_appName [options]');
    print('');
    print('Options:');
    print(_argParser.usage);
  }
}
