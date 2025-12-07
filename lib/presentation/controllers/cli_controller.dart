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
    final platforms = _getPlatforms();
    final includeLinterRules = _getLinterRulesChoice();

    final config = ProjectConfig(
      projectName: projectName,
      organizationName: organization,
      platforms: platforms,
      stateManagement: StateManagementType.bloc,
      architecture: ArchitectureType.cleanArchitecture,
      includeGoRouter: true,
      includeLinterRules: includeLinterRules,
      includeFreezed: true,
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

  List<PlatformType> _getPlatforms() {
    print('');
    print('${_brightYellow}${_bold}🌍 Platform Selection${_reset}');
    print('${_yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_reset}');
    print('');
    
    print('${_brightCyan}${_bold}Choose your platform configuration:${_reset}');
    print('${_dim}1.${_reset} ${_brightGreen}Mobile Only${_reset} ${_dim}- Android & iOS (Default)${_reset}');
    print('${_dim}2.${_reset} ${_brightGreen}Web Only${_reset} ${_dim}- Web browser${_reset}');
    print('${_dim}3.${_reset} ${_brightGreen}Desktop Only${_reset} ${_dim}- Windows, macOS, Linux${_reset}');
    print('${_dim}4.${_reset} ${_brightGreen}Mobile + Web${_reset} ${_dim}- Android, iOS, Web${_reset}');
    print('${_dim}5.${_reset} ${_brightGreen}Mobile + Desktop${_reset} ${_dim}- Android, iOS, Windows, macOS, Linux${_reset}');
    print('${_dim}6.${_reset} ${_brightGreen}Web + Desktop${_reset} ${_dim}- Web, Windows, macOS, Linux${_reset}');
    print('${_dim}7.${_reset} ${_brightGreen}All Platforms${_reset} ${_dim}- Android, iOS, Web, Windows, macOS, Linux${_reset}');
    print('${_dim}8.${_reset} ${_brightGreen}Custom Selection${_reset} ${_dim}- Choose platforms individually${_reset}');
    print('');
    
    while (true) {
      stdout.write('${_brightGreen}${_bold}🌍 Your choice (1-8):${_reset} ');
      final choice = stdin.readLineSync()?.trim() ?? '';
      
      switch (choice) {
        case '1':
          return [PlatformType.mobile];
        case '2':
          return [PlatformType.web];
        case '3':
          return [PlatformType.desktop];
        case '4':
          return [PlatformType.mobile, PlatformType.web];
        case '5':
          return [PlatformType.mobile, PlatformType.desktop];
        case '6':
          return [PlatformType.web, PlatformType.desktop];
        case '7':
          return [PlatformType.mobile, PlatformType.web, PlatformType.desktop];
        case '8':
          return _getCustomPlatformSelection();
        default:
          print('${_brightRed}❌ Invalid choice. Please enter 1-8.${_reset}');
      }
    }
  }

  List<PlatformType> _getCustomPlatformSelection() {
    print('');
    print('${_brightCyan}${_bold}🔧 Custom Platform Selection${_reset}');
    print('${_dim}Select platforms individually (y/n for each):${_reset}');
    print('');
    
    final platforms = <PlatformType>[];
    
    // Quick selection options
    print('${_brightYellow}${_bold}⚡ Quick Options:${_reset}');
    print('${_dim}• Type "mobile" to pre-select Android + iOS${_reset}');
    print('${_dim}• Type "desktop" to pre-select Windows + macOS + Linux${_reset}');
    print('${_dim}• Type "all" to pre-select all platforms${_reset}');
    print('${_dim}• Type "none" to skip all platforms${_reset}');
    print('');
    
    // Quick selection for pre-filling
    String quickChoice = '';
    while (true) {
      stdout.write('${_brightGreen}${_bold}⚡ Quick selection (or press Enter for individual):${_reset} ');
      quickChoice = stdin.readLineSync()?.trim().toLowerCase() ?? '';
      
      switch (quickChoice) {
        case 'mobile':
          print('${_brightGreen}✅ Pre-selected: Mobile (Android & iOS)${_reset}');
          break;
        case 'desktop':
          print('${_brightGreen}✅ Pre-selected: Desktop (Windows, macOS, Linux)${_reset}');
          break;
        case 'all':
          print('${_brightGreen}✅ Pre-selected: All Platforms${_reset}');
          break;
        case 'none':
          print('${_brightGreen}✅ Pre-selected: No Platforms${_reset}');
          break;
        case '':
          // Empty input - no pre-selection
          break;
        default:
          // Invalid input - show error and ask again
          print('${_brightRed}❌ Invalid quick selection. Please enter "mobile", "desktop", "all", "none", or press Enter for individual selection.${_reset}');
          print('');
          continue;
      }
      
      // If we reach here, we have a valid selection
      break;
    }
    
    // Individual selection with pre-filling
    print('');
    print('${_brightCyan}${_bold}📱 Mobile Platforms:${_reset}');
    bool includeMobile = false;
    if (quickChoice == 'mobile' || quickChoice == 'all') {
      // For mobile selection, ask about both Android and iOS
      bool includeAndroid = _getYesNoChoice('   Include Android?', defaultYes: true);
      bool includeIOS = _getYesNoChoice('   Include iOS?', defaultYes: true);
      includeMobile = includeAndroid || includeIOS;
    } else if (quickChoice == 'desktop' || quickChoice == 'none') {
      // Skip mobile for desktop/none selections
      includeMobile = false;
    } else {
      includeMobile = _getYesNoChoice('   Include Android?', defaultYes: false);
    }
    if (includeMobile) {
      platforms.add(PlatformType.mobile);
    }
    
    // Only ask about Web if not specifically excluded
    if (quickChoice != 'mobile' && quickChoice != 'desktop' && quickChoice != 'none') {
      print('');
      print('${_brightCyan}${_bold}🌐 Web Platform:${_reset}');
      bool includeWeb = false;
      if (quickChoice == 'all') {
        includeWeb = _getYesNoChoice('   Include Web?', defaultYes: true);
      } else {
        includeWeb = _getYesNoChoice('   Include Web?', defaultYes: false);
      }
      if (includeWeb) {
        platforms.add(PlatformType.web);
      }
    }
    
    // Only ask about Desktop if not specifically excluded
    if (quickChoice != 'mobile' && quickChoice != 'none') {
      print('');
      print('${_brightCyan}${_bold}💻 Desktop Platforms:${_reset}');
      bool includeDesktop = false;
      if (quickChoice == 'desktop' || quickChoice == 'all') {
        // For desktop selection, ask about Windows, macOS, and Linux
        bool includeWindows = _getYesNoChoice('   Include Windows?', defaultYes: true);
        bool includeMacOS = _getYesNoChoice('   Include macOS?', defaultYes: true);
        bool includeLinux = _getYesNoChoice('   Include Linux?', defaultYes: true);
        includeDesktop = includeWindows || includeMacOS || includeLinux;
      } else {
        includeDesktop = _getYesNoChoice('   Include Windows?', defaultYes: false);
      }
      if (includeDesktop) {
        platforms.add(PlatformType.desktop);
      }
    }
    
    if (platforms.isEmpty) {
      print('${_brightYellow}⚠️  No platforms selected. Defaulting to Mobile (Android & iOS).${_reset}');
      platforms.add(PlatformType.mobile);
    }
    
    return platforms;
  }


  bool _getLinterRulesChoice() {
    print('');
    print('${_brightYellow}${_bold}🔍 Code Quality${_reset}');
    print('${_yellow}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_reset}');
    print('');
    
    return _getYesNoChoice('${_brightCyan}${_bold}✨ Add custom linter rules?${_reset} ${_dim}(Enhanced code quality)${_reset}', defaultYes: false);
  }

  // Freezed is now always included - no need to ask user

  bool _getYesNoChoice(String question, {bool defaultYes = false}) {
    final defaultText = defaultYes ? 'Y/n' : 'y/N';
    
    while (true) {
      stdout.write('${_brightGreen}${_bold}$question${_reset} ${_dim}($defaultText)${_reset} ');
      final response = stdin.readLineSync()?.trim().toLowerCase() ?? '';
      
      if (response.isEmpty) {
        // Don't accept empty input - require explicit answer
        print('${_brightRed}❌ Please enter y/yes or n/no.${_reset}');
        continue;
      }
      
      if (response == 'y' || response == 'yes') {
        return true;
      }
      
      if (response == 'n' || response == 'no') {
        return false;
      }
      
      // Invalid input - ask again
      print('${_brightRed}❌ Invalid answer. Please enter y/yes or n/no.${_reset}');
    }
  }

  void _printConfigurationSummary(ProjectConfig config) {
    print('');
    print('${_brightMagenta}${_bold}📋 Configuration Summary${_reset}');
    print('${_magenta}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${_reset}');
    print('');
    
    print('${_brightCyan}${_bold}Project:${_reset} ${_brightGreen}${config.projectName}${_reset}');
    print('${_brightCyan}${_bold}Organization:${_reset} ${_brightGreen}${config.organizationName}${_reset}');
    print('${_brightCyan}${_bold}Platforms:${_reset} ${_brightGreen}${config.platforms.join(', ')}${_reset}');
    print('${_brightCyan}${_bold}State Management:${_reset} ${_brightGreen}BLoC${_reset}');
    print('${_brightCyan}${_bold}Navigation:${_reset} ${_brightGreen}Go Router${_reset}');
    print('${_brightCyan}${_bold}Architecture:${_reset} ${_brightGreen}Clean Architecture${_reset}');
    
    if (config.includeLinterRules) {
      print('${_brightCyan}${_bold}Code Quality:${_reset} ${_brightGreen}Custom Linter Rules${_reset}');
    }
    
    print('${_brightCyan}${_bold}Code Generation:${_reset} ${_brightGreen}Freezed${_reset}');
    
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
      
      print('');
      print('${_brightYellow}${_bold}For Freezed code generation:${_reset}');
      print('${_dim}   dart run build_runner build -d${_reset}');
      
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