// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:io';
import '../../domain/entities/project_config.dart';
import '../../domain/repositories/project_repository.dart';

class CliController {
  final ProjectRepository _projectRepository;

  CliController(this._projectRepository);

  // ANSI Color Codes for better styling
  static const String _reset = '\x1B[0m';
  static const String _bold = '\x1B[1m';
  static const String _dim = '\x1B[2m';
  
  // Colors
  static const String _red = '\x1B[31m';
  static const String _green = '\x1B[32m';
  static const String _yellow = '\x1B[33m';
  static const String _magenta = '\x1B[35m';
  static const String _cyan = '\x1B[36m';
  
  // Bright colors
  static const String _brightRed = '\x1B[91m';
  static const String _brightGreen = '\x1B[92m';
  static const String _brightYellow = '\x1B[93m';
  static const String _brightBlue = '\x1B[94m';
  static const String _brightMagenta = '\x1B[95m';
  static const String _brightCyan = '\x1B[96m';

  void runInteractiveMode() {
    _printWelcomeMessage();
    
    final projectName = _getProjectName();
    final organization = _getOrganization();
    _getPlatforms();
    final stateManagement = _getStateManagement();
    final includeGoRouter = _getGoRouterChoice();
    final includeCleanArchitecture = _getCleanArchitectureChoice();
    final includeLinterRules = _getLinterRulesChoice();
    final includeFreezed = _getFreezedChoice(stateManagement);

    final config = ProjectConfig(
      projectName: projectName,
      organizationName: organization,
      stateManagement: stateManagement,
      includeGoRouter: includeGoRouter,
      includeCleanArchitecture: includeCleanArchitecture,
      includeLinterRules: includeLinterRules,
      includeFreezed: includeFreezed,
    );

    _printConfigurationSummary(config);
    
    if (_confirmConfiguration(config)) {
      _createProject(config);
    } else {
      _printCancelledMessage();
    }
  }

  void _printWelcomeMessage() {
    print('');
    print('${_brightMagenta}${_bold}  ███████╗██╗     ██╗   ██╗████████╗████████╗███████╗██████╗ ${_reset}');
    print('${_brightMagenta}${_bold}  ██╔════╝██║     ██║   ██║╚══██╔══╝╚══██╔══╝██╔════╝██╔══██╗${_reset}');
    print('${_brightMagenta}${_bold}  █████╗  ██║     ██║   ██║   ██║      ██║   █████╗  ██████╔╝${_reset}');
    print('${_brightMagenta}${_bold}  ██╔══╝  ██║     ██║   ██║   ██║      ██║   ██╔══╝  ██╔══██╗${_reset}');
    print('${_brightMagenta}${_bold}  ██║     ███████╗╚██████╔╝   ██║      ██║   ███████╗██║  ██║${_reset}');
    print('${_brightMagenta}${_bold}  ╚═╝     ╚══════╝ ╚═════╝    ╚═╝      ╚═╝   ╚══════╝╚═╝  ╚═╝${_reset}');
    print('${_brightMagenta}${_bold}  ███████╗ ██████╗ ██████╗  ███████╗███████╗${_reset}');
    print('${_brightMagenta}${_bold}  ██╔════╝██╔═══██╗██╔══██╗██╔════╝ ██╔════╝${_reset}');
    print('${_brightMagenta}${_bold}  █████╗  ██║   ██║██████╔╝██║  ███╗█████╗  ${_reset}');
    print('${_brightMagenta}${_bold}  ██╔══╝  ██║   ██║██╔══██╗██║   ██║██╔══╝  ${_reset}');
    print('${_brightMagenta}${_bold}  ██║     ╚██████╔╝██║  ██║╚██████╔╝███████╗${_reset}');
    print('${_brightMagenta}${_bold}  ╚═╝      ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝${_reset}');
    print('${_brightYellow}${_bold}                    🚀 FLUTTERFORGE CLI 🚀                    ${_reset}');
    print('${_dim}              The Ultimate Flutter Project Generator              ${_reset}');
    print('');
    print('${_brightYellow}${_bold}✨ Welcome to FlutterForge! Let\'s create something amazing! ✨${_reset}');
    print('');
  }

  String _getProjectName() {
    print('${_brightBlue}${_bold}📝 Project Configuration${_reset}');
    print('${_cyan}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_reset}');
    print('');
    
    while (true) {
      stdout.write('${_brightGreen}${_bold}🏗️  Project Name:${_reset} ${_dim}(e.g., my_awesome_app)${_reset} ');
      final name = stdin.readLineSync()?.trim() ?? '';
      
      if (name.isEmpty) {
        print('${_brightRed}❌ Project name cannot be empty. Please try again.${_reset}');
        continue;
      }
      
      if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
        print('${_brightRed}❌ Project name must be lowercase with underscores only.${_reset}');
        print('${_dim}   Example: my_awesome_app, flutter_app, todo_list${_reset}');
        continue;
      }
      
      return name;
    }
  }

  String _getOrganization() {
    while (true) {
      stdout.write('${_brightGreen}${_bold}🏢 Organization:${_reset} ${_dim}(e.g., com.example)${_reset} ');
      final org = stdin.readLineSync()?.trim() ?? '';
      
      if (org.isEmpty) {
        print('${_brightRed}❌ Organization cannot be empty. Please try again.${_reset}');
        continue;
      }
      
      if (!RegExp(r'^[a-z][a-z0-9.]*$').hasMatch(org)) {
        print('${_brightRed}❌ Organization must be lowercase with dots only.${_reset}');
        print('${_dim}   Example: com.example, dev.mycompany, app.mystartup${_reset}');
        continue;
      }
      
      return org;
    }
  }

  List<String> _getPlatforms() {
    print('');
    print('${_brightYellow}${_bold}🌍 Platform Selection${_reset}');
    print('${_yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_reset}');
    print('');
    
    final platforms = <String>[];
    
    // Mobile platforms
    print('${_brightCyan}${_bold}📱 Mobile Platforms:${_reset}');
    if (_getYesNoChoice('   Include Android?', defaultYes: true)) {
      platforms.add('android');
    }
    if (_getYesNoChoice('   Include iOS?', defaultYes: true)) {
      platforms.add('ios');
    }
    
    // Web platform
    print('');
    print('${_brightCyan}${_bold}🌐 Web Platform:${_reset}');
    if (_getYesNoChoice('   Include Web?', defaultYes: false)) {
      platforms.add('web');
    }
    
    // Desktop platforms
    print('');
    print('${_brightCyan}${_bold}💻 Desktop Platforms:${_reset}');
    if (_getYesNoChoice('   Include Windows?', defaultYes: false)) {
      platforms.add('windows');
    }
    if (_getYesNoChoice('   Include macOS?', defaultYes: false)) {
      platforms.add('macos');
    }
    if (_getYesNoChoice('   Include Linux?', defaultYes: false)) {
      platforms.add('linux');
    }
    
    if (platforms.isEmpty) {
      print('${_brightYellow}⚠️  No platforms selected. Defaulting to Android and iOS.${_reset}');
      platforms.addAll(['android', 'ios']);
    }
    
    return platforms;
  }

  StateManagementType _getStateManagement() {
    print('');
    print('${_brightYellow}${_bold}🎯 State Management${_reset}');
    print('${_yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_reset}');
    print('');
    
    print('${_brightCyan}${_bold}Choose your state management solution:${_reset}');
    print('${_dim}1.${_reset} ${_brightGreen}BLoC${_reset} ${_dim}- Business Logic Component (Recommended)${_reset}');
    print('${_dim}2.${_reset} ${_brightGreen}Cubit${_reset} ${_dim}- Simpler BLoC alternative${_reset}');
    print('${_dim}3.${_reset} ${_brightGreen}Provider${_reset} ${_dim}- Simple state management${_reset}');
    print('${_dim}4.${_reset} ${_brightGreen}None${_reset} ${_dim}- Basic Flutter state management${_reset}');
    print('');
    
    while (true) {
      stdout.write('${_brightGreen}${_bold}🎯 Your choice (1-4):${_reset} ');
      final choice = stdin.readLineSync()?.trim() ?? '';
      
      switch (choice) {
        case '1':
          return StateManagementType.bloc;
        case '2':
          return StateManagementType.cubit;
        case '3':
          return StateManagementType.provider;
        case '4':
          return StateManagementType.none;
        default:
          print('${_brightRed}❌ Invalid choice. Please enter 1, 2, 3, or 4.${_reset}');
      }
    }
  }

  bool _getGoRouterChoice() {
    print('');
    print('${_brightYellow}${_bold}🛣️  Navigation${_reset}');
    print('${_yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_reset}');
    print('');
    
    return _getYesNoChoice('${_brightCyan}${_bold}🚀 Include Go Router for navigation?${_reset} ${_dim}(Declarative routing)${_reset}', defaultYes: false);
  }

  bool _getCleanArchitectureChoice() {
    print('');
    print('${_brightYellow}${_bold}🏗️  Architecture${_reset}');
    print('${_yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_reset}');
    print('');
    
    return _getYesNoChoice('${_brightCyan}${_bold}🏛️  Apply Clean Architecture principles?${_reset} ${_dim}(Core, Domain, Data, Presentation layers)${_reset}', defaultYes: false);
  }

  bool _getLinterRulesChoice() {
    print('');
    print('${_brightYellow}${_bold}🔍 Code Quality${_reset}');
    print('${_yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_reset}');
    print('');
    
    return _getYesNoChoice('${_brightCyan}${_bold}✨ Add custom linter rules?${_reset} ${_dim}(Enhanced code quality)${_reset}', defaultYes: false);
  }

  bool _getFreezedChoice(StateManagementType stateManagement) {
    if (stateManagement == StateManagementType.bloc) {
      print('');
      print('${_brightYellow}${_bold}❄️  Code Generation${_reset}');
      print('${_yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_reset}');
      print('');
      
      return _getYesNoChoice('${_brightCyan}${_bold}❄️  Use Freezed for BLoC, entities, and models?${_reset} ${_dim}(Immutable data classes)${_reset}', defaultYes: false);
    }
    return false;
  }

  bool _getYesNoChoice(String question, {bool defaultYes = false}) {
    final defaultText = defaultYes ? 'Y/n' : 'y/N';
    stdout.write('${_brightGreen}${_bold}$question${_reset} ${_dim}($defaultText)${_reset} ');
    final response = stdin.readLineSync()?.trim().toLowerCase() ?? '';
    
    if (response.isEmpty) {
      return defaultYes;
    }
    
    return response == 'y' || response == 'yes';
  }

  void _printConfigurationSummary(ProjectConfig config) {
    print('');
    print('${_brightMagenta}${_bold}📋 Configuration Summary${_reset}');
    print('${_magenta}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_reset}');
    print('');
    
    print('${_brightCyan}${_bold}🏗️  Project:${_reset} ${_brightGreen}${config.projectName}${_reset}');
    print('${_brightCyan}${_bold}🏢 Organization:${_reset} ${_brightGreen}${config.organizationName}${_reset}');
    print('${_brightCyan}${_bold}🌍 Platforms:${_reset} ${_brightGreen}${config.platforms.join(', ')}${_reset}');
    print('${_brightCyan}${_bold}🎯 State Management:${_reset} ${_brightGreen}${config.stateManagement.name.toUpperCase()}${_reset}');
    
    if (config.includeGoRouter) {
      print('${_brightCyan}${_bold}🛣️  Navigation:${_reset} ${_brightGreen}Go Router${_reset}');
    }
    
    if (config.includeCleanArchitecture) {
      print('${_brightCyan}${_bold}🏛️  Architecture:${_reset} ${_brightGreen}Clean Architecture${_reset}');
    }
    
    if (config.includeLinterRules) {
      print('${_brightCyan}${_bold}🔍 Code Quality:${_reset} ${_brightGreen}Custom Linter Rules${_reset}');
    }
    
    if (config.includeFreezed) {
      print('${_brightCyan}${_bold}❄️  Code Generation:${_reset} ${_brightGreen}Freezed${_reset}');
    }
    
    print('');
  }

  bool _confirmConfiguration(ProjectConfig config) {
    return _getYesNoChoice('${_brightYellow}${_bold}🚀 Ready to create your Flutter project?${_reset}', defaultYes: true);
  }

  void _createProject(ProjectConfig config) {
    print('');
    print('${_brightGreen}${_bold}🚀 Creating your Flutter project...${_reset}');
    print('${_green}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_reset}');
    print('');
    
    try {
      _projectRepository.createProject(config);
      
      print('');
      print('${_brightGreen}${_bold}✅ Project created successfully!${_reset}');
      print('');
      print('${_brightCyan}${_bold}🎉 Next steps:${_reset}');
      print('${_dim}   cd ${config.projectName}${_reset}');
      print('${_dim}   flutter pub get${_reset}');
      print('${_dim}   flutter run${_reset}');
      
      print('');
      print('${_brightYellow}${_bold}🌍 For localization (if needed):${_reset}');
      print('${_dim}   dart run intl_utils:generate${_reset}');
      
      if (config.includeFreezed) {
        print('');
        print('${_brightYellow}${_bold}❄️  For Freezed code generation:${_reset}');
        print('${_dim}   dart run build_runner build -d${_reset}');
      }
      
      print('');
      print('${_brightMagenta}${_bold}✨ Happy coding with FlutterForge! ✨${_reset}');
      print('');
      
    } catch (e) {
      print('');
      print('${_brightRed}${_bold}❌ Error creating project:${_reset}');
      print('${_red}$e${_reset}');
      print('');
      print('${_brightYellow}${_bold}💡 Troubleshooting tips:${_reset}');
      print('${_dim}   - Check your Flutter installation${_reset}');
      print('${_dim}   - Ensure you have write permissions${_reset}');
      print('${_dim}   - Try running: flutter doctor${_reset}');
      print('');
    }
  }

  void _printCancelledMessage() {
    print('');
    print('${_brightYellow}${_bold}⚠️  Project creation cancelled.${_reset}');
    print('');
    print('${_dim}Run ${_reset}${_brightCyan}flutterforge${_reset}${_dim} again when you\'re ready!${_reset}');
    print('');
  }
} 