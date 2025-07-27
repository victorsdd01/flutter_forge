import 'dart:io';
import '../../domain/entities/project_config.dart';
import '../../domain/usecases/create_project_usecase.dart';
import '../../domain/usecases/validate_project_config_usecase.dart';

/// Controller for CLI operations
class CLIController {
  final CreateProjectUseCase _createProjectUseCase;
  final ValidateProjectConfigUseCase _validateProjectConfigUseCase;

  CLIController({
    required CreateProjectUseCase createProjectUseCase,
    required ValidateProjectConfigUseCase validateProjectConfigUseCase,
  })  : _createProjectUseCase = createProjectUseCase,
        _validateProjectConfigUseCase = validateProjectConfigUseCase;

  /// Runs the CLI in interactive mode
  Future<void> runInteractiveMode() async {
    _printWelcome();
    _printLogo();

    final projectName = _promptForProjectName();
    final organizationName = _promptForOrganizationName();
    final stateManagement = _promptForStateManagement();
    final includeGoRouter = _promptForGoRouter();

    final config = ProjectConfig(
      projectName: projectName,
      organizationName: organizationName,
      stateManagement: stateManagement,
      includeGoRouter: includeGoRouter,
    );

    await _confirmAndCreateProject(config);
  }

  /// Runs the CLI in non-interactive mode
  Future<void> runNonInteractiveMode(ProjectConfig config) async {
    await _createProjectUseCase.execute(config);
  }

  void _printWelcome() {
    print('\n${_colorize('🎉 Welcome to FlutterForge!', Colors.cyan, bold: true)}');
    print('${_colorize('✨ Forge your Flutter projects with ease', Colors.blue)}\n');
  }

  void _printLogo() {
    print(_colorize('╔══════════════════════════════════════════════════════════════╗', Colors.purple));
    print('${_colorize('║', Colors.purple)}                                                              ${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}    ${_colorize('███████╗██╗      █████╗ ████████╗████████╗███████╗██████╗ ', Colors.cyan)}${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}    ${_colorize('██╔════╝██║     ██╔══██╗╚══██╔══╝╚══██╔══╝██╔════╝██╔══██╗', Colors.cyan)}${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}    ${_colorize('█████╗  ██║     ███████║   ██║      ██║   █████╗  ██████╔╝', Colors.cyan)}${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}    ${_colorize('██╔══╝  ██║     ██╔══██║   ██║      ██║   ██╔══╝  ██╔══██╗', Colors.cyan)}${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}    ${_colorize('██║     ███████╗██║  ██║   ██║      ██║   ███████╗██║  ██║', Colors.cyan)}${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}    ${_colorize('╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚══════╝╚═╝  ╚═╝', Colors.cyan)}${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}                                                              ${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}    ${_colorize('███████╗ ██████╗ ██████╗  ██████╗ ███████╗', Colors.yellow)}${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}    ${_colorize('██╔════╝██╔═══██╗██╔══██╗██╔═══██╗██╔════╝', Colors.yellow)}${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}    ${_colorize('█████╗  ██║   ██║██████╔╝██║   ██║█████╗  ', Colors.yellow)}${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}    ${_colorize('██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝  ', Colors.yellow)}${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}    ${_colorize('██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗', Colors.yellow)}${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}    ${_colorize('╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝', Colors.yellow)}${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}                                                              ${_colorize('║', Colors.purple)}');
    print('${_colorize('║', Colors.purple)}                    ${_colorize('Flutter Project Generator', Colors.yellow, bold: true)}                 ${_colorize('║', Colors.purple)}');
    print(_colorize('╚══════════════════════════════════════════════════════════════╝', Colors.purple));
  }

  String _promptForProjectName() {
    print('${_colorize('📱 Let\'s start with your project details!', Colors.green, bold: true)}\n');
    
    while (true) {
      stdout.write(_colorize('  Project name: ', Colors.blue));
      final input = stdin.readLineSync()?.trim();
      
      if (input != null && input.isNotEmpty) {
        if (_validateProjectConfigUseCase.isValidProjectName(input)) {
          return input;
        } else {
          print(_colorize('  ❌ Invalid project name. Use lowercase letters, numbers, and underscores only.', Colors.red));
          print('${_colorize('  💡 Example: my_awesome_app', Colors.yellow)}\n');
        }
      } else {
        print('${_colorize('  ❌ Project name cannot be empty.', Colors.red)}\n');
      }
    }
  }

  String _promptForOrganizationName() {
    print('\n${_colorize('🏢 Now let\'s set up your organization details!', Colors.green, bold: true)}\n');
    
    while (true) {
      stdout.write(_colorize('  Organization name (e.g., com.example): ', Colors.blue));
      final input = stdin.readLineSync()?.trim();
      
      if (input != null && input.isNotEmpty) {
        if (_validateProjectConfigUseCase.isValidOrganizationName(input)) {
          return input;
        } else {
          print(_colorize('  ❌ Invalid organization name. Use lowercase letters, numbers, and dots only.', Colors.red));
          print('${_colorize('  💡 Example: com.mycompany', Colors.yellow)}\n');
        }
      } else {
        print('${_colorize('  ❌ Organization name cannot be empty.', Colors.red)}\n');
      }
    }
  }

  StateManagementType _promptForStateManagement() {
    print('\n${_colorize('🔄 Choose your state management solution:', Colors.green, bold: true)}\n');
    print(_colorize('  ┌─ State Management Options ─────────────────────────┐', Colors.cyan));
    print('${_colorize('  │', Colors.cyan)} ${_colorize('1. BLoC (Business Logic Component)', Colors.yellow)}                ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Event-driven architecture', Colors.white)}                     ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Great for complex state management', Colors.white)}           ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}                                                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('2. Cubit (Simplified BLoC)', Colors.yellow)}                        ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Simpler than BLoC', Colors.white)}                            ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Function-based state changes', Colors.white)}                 ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}                                                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('3. Provider', Colors.yellow)}                                       ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Simple and lightweight', Colors.white)}                       ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Perfect for small to medium apps', Colors.white)}            ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}                                                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('4. None (Basic Flutter project)', Colors.yellow)}                   ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• No state management', Colors.white)}                          ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Start with basic Flutter setup', Colors.white)}              ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  └────────────────────────────────────────────────────┘', Colors.cyan)}\n');

    while (true) {
      stdout.write(_colorize('  Select an option (1-4): ', Colors.blue));
      final input = stdin.readLineSync()?.trim();
      
      switch (input) {
        case '1':
          return StateManagementType.bloc;
        case '2':
          return StateManagementType.cubit;
        case '3':
          return StateManagementType.provider;
        case '4':
          return StateManagementType.none;
        default:
          print('${_colorize('  ❌ Please enter a valid choice (1-4).', Colors.red)}\n');
      }
    }
  }

  bool _promptForGoRouter() {
    print('\n${_colorize('🗺️  Navigation and Routing:', Colors.green, bold: true)}\n');
    print(_colorize('  ┌─ Go Router Configuration ──────────────────────────┐', Colors.magenta));
    print('${_colorize('  │', Colors.magenta)} ${_colorize('Would you like to include Go Router?', Colors.yellow)}              ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)}                                                    ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)} ${_colorize('✅ Benefits:', Colors.green)}                                       ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)}    ${_colorize('• Declarative routing', Colors.white)}                           ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)}    ${_colorize('• Deep linking support', Colors.white)}                          ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)}    ${_colorize('• URL-based navigation', Colors.white)}                          ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)}    ${_colorize('• Web support', Colors.white)}                                   ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)}    ${_colorize('• Best practices configuration', Colors.white)}                  ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)}                                                    ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)} ${_colorize('📁 Will create:', Colors.blue)}                                    ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)}    ${_colorize('• lib/routes/ directory', Colors.white)}                        ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)}    ${_colorize('• app_router.dart with routes', Colors.white)}                  ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)}    ${_colorize('• Sample pages (home, about, settings)', Colors.white)}         ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  │', Colors.magenta)}    ${_colorize('• Navigation service', Colors.white)}                            ${_colorize('│', Colors.magenta)}');
    print('${_colorize('  └────────────────────────────────────────────────────┘', Colors.magenta)}\n');

    while (true) {
      stdout.write(_colorize('  Include Go Router? (Y/n): ', Colors.blue));
      final input = stdin.readLineSync()?.trim().toLowerCase();
      
      if (input == 'y' || input == 'yes' || input == '') {
        return true;
      } else if (input == 'n' || input == 'no') {
        return false;
      } else {
        print('${_colorize('  ❌ Please enter y/yes or n/no.', Colors.red)}\n');
      }
    }
  }

  Future<void> _confirmAndCreateProject(ProjectConfig config) async {
    print('\n${_colorize('📋 Project Configuration Summary:', Colors.green, bold: true)}\n');
    print(_colorize('  ┌─ Configuration ───────────────────────────────────┐', Colors.cyan));
    print('${_colorize('  │', Colors.cyan)} ${_colorize('Project Name:', Colors.yellow)} ${config.projectName.padRight(30)} ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('Organization:', Colors.yellow)} ${config.organizationName.padRight(30)} ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('State Management:', Colors.yellow)} ${config.stateManagement.displayName.padRight(25)} ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('Go Router:', Colors.yellow)} ${(config.includeGoRouter ? 'Yes' : 'No').padRight(35)} ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  └────────────────────────────────────────────────────┘', Colors.cyan)}\n');

    while (true) {
      stdout.write(_colorize('  ✅ Proceed with project creation? (Y/n): ', Colors.blue));
      final input = stdin.readLineSync()?.trim().toLowerCase();
      
      if (input == 'y' || input == 'yes' || input == '') {
        await _createProject(config);
        break;
      } else if (input == 'n' || input == 'no') {
        print('\n${_colorize('  ❌ Project creation cancelled.', Colors.red)}');
        print('${_colorize('  👋 Thanks for using VMGV CLI!', Colors.cyan)}\n');
        exit(0);
      } else {
        print('${_colorize('  ❌ Please enter y/yes or n/no.', Colors.red)}\n');
      }
    }
  }

  Future<void> _createProject(ProjectConfig config) async {
    try {
      print('\n${_colorize('🚀 Creating your Flutter project...', Colors.green, bold: true)}\n');
      
      await _createProjectUseCase.execute(config);
      
      print(_colorize('  ✅ Flutter project created successfully!', Colors.green));
      
      if (config.stateManagement != StateManagementType.none) {
        print(_colorize('  📦 Adding ${config.stateManagement.shortName} dependencies...', Colors.blue));
        print(_colorize('  ✅ ${config.stateManagement.shortName} setup complete!', Colors.green));
      }

      if (config.includeGoRouter) {
        print(_colorize('  🗺️  Adding Go Router configuration...', Colors.magenta));
        print(_colorize('  ✅ Go Router setup complete!', Colors.green));
      }

      _printSuccessMessage(config);
      _printNextSteps(config);

    } catch (e) {
      print('\n${_colorize('  ❌ Error creating project: $e', Colors.red)}');
      print('${_colorize('  🔧 Please check your Flutter installation and try again.', Colors.yellow)}\n');
      exit(1);
    }
  }

  void _printSuccessMessage(ProjectConfig config) {
    print('\n${_colorize('🎉 Project setup complete!', Colors.green, bold: true)}\n');
    print(_colorize('  ┌─ Success ─────────────────────────────────────────┐', Colors.green));
    print('${_colorize('  │', Colors.green)} ${_colorize('Your Flutter project has been created!', Colors.white)}            ${_colorize('│', Colors.green)}');
    print('${_colorize('  │', Colors.green)}                                                    ${_colorize('│', Colors.green)}');
    print('${_colorize('  │', Colors.green)} ${_colorize('📁 Location:', Colors.yellow)} ${Directory.current.path}/${config.projectName}');
    print('${_colorize('  │', Colors.green)} ${_colorize('🎯 State Management:', Colors.yellow)} ${config.stateManagement.displayName}');
    print('${_colorize('  │', Colors.green)} ${_colorize('🏢 Organization:', Colors.yellow)} ${config.organizationName}');
    print('${_colorize('  │', Colors.green)} ${_colorize('🗺️  Go Router:', Colors.yellow)} ${config.includeGoRouter ? 'Yes' : 'No'}');
    print('${_colorize('  └────────────────────────────────────────────────────┘', Colors.green)}\n');
  }

  void _printNextSteps(ProjectConfig config) {
    print('${_colorize('  📚 Next Steps:', Colors.blue, bold: true)}\n');
    print(_colorize('  ┌─ Commands ─────────────────────────────────────────┐', Colors.cyan));
    print('${_colorize('  │', Colors.cyan)} ${_colorize('cd ${config.projectName}', Colors.yellow)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('flutter pub get', Colors.yellow)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('flutter run', Colors.yellow)}');
    print('${_colorize('  └────────────────────────────────────────────────────┘', Colors.cyan)}\n');
    
    print(_colorize('  💡 Tips:', Colors.yellow, bold: true));
    print(_colorize('  • Run \'flutter doctor\' to check your setup', Colors.white));
    print(_colorize('  • Use \'flutter create --help\' for more options', Colors.white));
    print('${_colorize('  • Check the README.md in your project for details', Colors.white)}\n');
    
    print('${_colorize('  🚀 Happy coding with Flutter!', Colors.green, bold: true)}\n');
  }

  /// Helper method to colorize text
  String _colorize(String text, Colors color, {bool bold = false}) {
    if (!stdout.hasTerminal) return text; // Don't colorize if no terminal
    
    final colorCode = _getColorCode(color);
    final boldCode = bold ? '\x1b[1m' : '';
    final resetCode = '\x1b[0m';
    
    return '$boldCode$colorCode$text$resetCode';
  }

  /// Get ANSI color code
  String _getColorCode(Colors color) {
    switch (color) {
      case Colors.black:
        return '\x1b[30m';
      case Colors.red:
        return '\x1b[31m';
      case Colors.green:
        return '\x1b[32m';
      case Colors.yellow:
        return '\x1b[33m';
      case Colors.blue:
        return '\x1b[34m';
      case Colors.magenta:
        return '\x1b[35m';
      case Colors.cyan:
        return '\x1b[36m';
      case Colors.white:
        return '\x1b[37m';
      case Colors.purple:
        return '\x1b[35m'; // Same as magenta for terminal compatibility
    }
  }
}

/// Color enum for CLI styling
enum Colors {
  black,
  red,
  green,
  yellow,
  blue,
  magenta,
  cyan,
  white,
  purple,
} 