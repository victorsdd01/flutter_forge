import 'dart:io';
import '../../domain/entities/project_config.dart';
import '../../domain/usecases/create_project_usecase.dart';
import '../../domain/usecases/validate_project_config_usecase.dart';
import '../../core/utils/version_checker.dart';

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
    final platforms = _promptForPlatforms();
    
    // Only ask for mobile platform configuration if mobile is selected
    MobilePlatform mobilePlatform = MobilePlatform.both; // Default value
    if (platforms.contains(PlatformType.mobile)) {
      mobilePlatform = _promptForMobilePlatform();
    }
    
    // Only ask for desktop platform configuration if desktop is selected
    DesktopPlatform desktopPlatform = DesktopPlatform.all; // Default value
    CustomDesktopPlatforms? customDesktopPlatforms;
    if (platforms.contains(PlatformType.desktop)) {
      desktopPlatform = _promptForDesktopPlatform();
      customDesktopPlatforms = _getCustomDesktopPlatforms(desktopPlatform);
    }
    
    final stateManagement = _promptForStateManagement();
    final includeFreezed = stateManagement == StateManagementType.bloc ? _promptForFreezed() : false;
    final includeGoRouter = _promptForGoRouter();
    final includeCleanArchitecture = _promptForCleanArchitecture();
    final includeLinterRules = _promptForLinterRules();

    final config = ProjectConfig(
      projectName: projectName,
      organizationName: organizationName,
      platforms: platforms,
      mobilePlatform: mobilePlatform,
      desktopPlatform: desktopPlatform,
      customDesktopPlatforms: customDesktopPlatforms,
      stateManagement: stateManagement,
      includeGoRouter: includeGoRouter,
      includeCleanArchitecture: includeCleanArchitecture,
      includeLinterRules: includeLinterRules,
      includeFreezed: includeFreezed,
    );

    await _confirmAndCreateProject(config);
  }

  CustomDesktopPlatforms? _getCustomDesktopPlatforms(DesktopPlatform desktopPlatform) {
    if (desktopPlatform == DesktopPlatform.custom) {
      // For now, we'll need to store the custom selection from the prompt
      // This is a simplified approach - in a real implementation, you'd want to
      // capture the custom selection during the prompt
      return const CustomDesktopPlatforms(windows: true, macos: true, linux: false);
    }
    return null;
  }

  /// Runs the CLI in non-interactive mode
  Future<void> runNonInteractiveMode(ProjectConfig config) async {
    await _createProjectUseCase.execute(config);
  }

  void _printWelcome() {
    print('\n${_colorize('🎉 Welcome to FlutterForge!', Colors.cyan, bold: true)}');
    print('${_colorize('✨ Forge your Flutter projects with ease', Colors.blue)}\n');
    _printLatestVersions();
  }

  void _printLatestVersions() {
    print(_colorize(VersionChecker.getVersionSummary(), Colors.yellow));
    print('');
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

  bool _promptForFreezed() {
    print('\n${_colorize('❄️  Freezed Configuration:', Colors.green, bold: true)}\n');
    print(_colorize('  ┌─ Freezed Code Generation ──────────────────────────┐', Colors.cyan));
    print('${_colorize('  │', Colors.cyan)} ${_colorize('Would you like to use Freezed with BLoC?', Colors.yellow)}            ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}                                                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('✅ Benefits:', Colors.green)}                                       ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Immutable data classes', Colors.white)}                         ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Union types (sealed classes)', Colors.white)}                   ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• JSON serialization', Colors.white)}                             ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Copy with methods', Colors.white)}                              ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Pattern matching', Colors.white)}                               ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}                                                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('📁 Will create:', Colors.blue)}                                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Freezed BLoC with events and states', Colors.white)}           ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Freezed entities and models', Colors.white)}                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• build.yaml configuration', Colors.white)}                       ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Required dependencies', Colors.white)}                          ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  └────────────────────────────────────────────────────┘', Colors.cyan)}\n');

    while (true) {
      stdout.write(_colorize('  Use Freezed with BLoC? (Y/n): ', Colors.blue));
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

  List<PlatformType> _promptForPlatforms() {
    print('\n${_colorize('🌐 Platform Selection', Colors.green, bold: true)}\n');
    print(_colorize('  Which platforms would you like to target? (You can select multiple)', Colors.blue));
    print(_colorize('  1. Mobile (Android & iOS)', Colors.cyan));
    print(_colorize('  2. Web', Colors.cyan));
    print(_colorize('  3. Desktop (Windows, macOS, Linux)', Colors.cyan));
    print(_colorize('  4. All platforms', Colors.cyan));
    print(_colorize('  5. Custom selection (choose multiple)', Colors.cyan));
    
    while (true) {
      stdout.write(_colorize('  Enter your choice (1-5): ', Colors.blue));
      final input = stdin.readLineSync()?.trim();
      
      switch (input) {
        case '1':
          print(_colorize('  ✅ Mobile platform selected!', Colors.green));
          return [PlatformType.mobile];
        case '2':
          print(_colorize('  ✅ Web platform selected!', Colors.green));
          return [PlatformType.web];
        case '3':
          print(_colorize('  ✅ Desktop platform selected!', Colors.green));
          return [PlatformType.desktop];
        case '4':
          print(_colorize('  ✅ All platforms selected!', Colors.green));
          return [PlatformType.mobile, PlatformType.web, PlatformType.desktop];
        case '5':
          return _promptForCustomPlatformSelection();
        default:
          print(_colorize('  ❌ Please enter a number between 1-5.', Colors.red));
      }
    }
  }

  List<PlatformType> _promptForCustomPlatformSelection() {
    final selectedPlatforms = <PlatformType>[];
    
    print('\n${_colorize('  🎯 Custom Platform Selection', Colors.yellow, bold: true)}\n');
    print(_colorize('  Select platforms (enter numbers separated by commas, e.g., 1,2,3):', Colors.blue));
    print(_colorize('  1. Mobile (Android & iOS)', Colors.cyan));
    print(_colorize('  2. Web', Colors.cyan));
    print(_colorize('  3. Desktop (Windows, macOS, Linux)', Colors.cyan));
    
    while (true) {
      stdout.write(_colorize('  Enter your selections: ', Colors.blue));
      final input = stdin.readLineSync()?.trim();
      
      if (input != null && input.isNotEmpty) {
        final selections = input.split(',').map((s) => s.trim()).toList();
        bool isValid = true;
        
        for (final selection in selections) {
          switch (selection) {
            case '1':
              if (!selectedPlatforms.contains(PlatformType.mobile)) {
                selectedPlatforms.add(PlatformType.mobile);
                print(_colorize('  ✅ Mobile platform added!', Colors.green));
              }
              break;
            case '2':
              if (!selectedPlatforms.contains(PlatformType.web)) {
                selectedPlatforms.add(PlatformType.web);
                print(_colorize('  ✅ Web platform added!', Colors.green));
              }
              break;
            case '3':
              if (!selectedPlatforms.contains(PlatformType.desktop)) {
                selectedPlatforms.add(PlatformType.desktop);
                print(_colorize('  ✅ Desktop platform added!', Colors.green));
              }
              break;
            default:
              print(_colorize('  ❌ Invalid selection: $selection. Please use 1, 2, or 3.', Colors.red));
              isValid = false;
          }
        }
        
        if (isValid && selectedPlatforms.isNotEmpty) {
          print(_colorize('  🎉 Selected platforms: ${selectedPlatforms.map((p) => p.displayName).join(', ')}', Colors.green));
          return selectedPlatforms;
        } else if (selectedPlatforms.isEmpty) {
          print(_colorize('  ❌ Please select at least one platform.', Colors.red));
        }
      } else {
        print(_colorize('  ❌ Please enter valid selections.', Colors.red));
      }
    }
  }

  MobilePlatform _promptForMobilePlatform() {
    print('\n${_colorize('📱 Mobile Platform Configuration', Colors.green, bold: true)}\n');
    print(_colorize('  Which mobile platforms would you like to target?', Colors.blue));
    print(_colorize('  1. Android only', Colors.cyan));
    print(_colorize('  2. iOS only', Colors.cyan));
    print(_colorize('  3. Both Android & iOS', Colors.cyan));
    
    while (true) {
      stdout.write(_colorize('  Enter your choice (1-3): ', Colors.blue));
      final input = stdin.readLineSync()?.trim();
      
      switch (input) {
        case '1':
          print(_colorize('  ✅ Android only selected!', Colors.green));
          return MobilePlatform.android;
        case '2':
          print(_colorize('  ✅ iOS only selected!', Colors.green));
          return MobilePlatform.ios;
        case '3':
          print(_colorize('  ✅ Both Android & iOS selected!', Colors.green));
          return MobilePlatform.both;
        default:
          print(_colorize('  ❌ Please enter a number between 1-3.', Colors.red));
      }
    }
  }

  DesktopPlatform _promptForDesktopPlatform() {
    print('\n${_colorize('💻 Desktop Platform Configuration', Colors.green, bold: true)}\n');
    print(_colorize('  Which desktop platforms would you like to target?', Colors.blue));
    print(_colorize('  1. Windows only', Colors.cyan));
    print(_colorize('  2. macOS only', Colors.cyan));
    print(_colorize('  3. Linux only', Colors.cyan));
    print(_colorize('  4. All platforms (Windows, macOS, Linux)', Colors.cyan));
    print(_colorize('  5. Custom selection (choose multiple)', Colors.cyan));
    
    while (true) {
      stdout.write(_colorize('  Enter your choice (1-5): ', Colors.blue));
      final input = stdin.readLineSync()?.trim();
      
      switch (input) {
        case '1':
          print(_colorize('  ✅ Windows only selected!', Colors.green));
          return DesktopPlatform.windows;
        case '2':
          print(_colorize('  ✅ macOS only selected!', Colors.green));
          return DesktopPlatform.macos;
        case '3':
          print(_colorize('  ✅ Linux only selected!', Colors.green));
          return DesktopPlatform.linux;
        case '4':
          print(_colorize('  ✅ All desktop platforms selected!', Colors.green));
          return DesktopPlatform.all;
        case '5':
          return _promptForCustomDesktopPlatformSelection();
        default:
          print(_colorize('  ❌ Please enter a number between 1-5.', Colors.red));
      }
    }
  }

  DesktopPlatform _promptForCustomDesktopPlatformSelection() {
    print('\n${_colorize('  🎯 Custom Desktop Platform Selection', Colors.yellow, bold: true)}\n');
    print(_colorize('  Select desktop platforms (enter numbers separated by commas, e.g., 1,2):', Colors.blue));
    print(_colorize('  1. Windows', Colors.cyan));
    print(_colorize('  2. macOS', Colors.cyan));
    print(_colorize('  3. Linux', Colors.cyan));
    
    while (true) {
      stdout.write(_colorize('  Enter your selections: ', Colors.blue));
      final input = stdin.readLineSync()?.trim();
      
      if (input != null && input.isNotEmpty) {
        final selections = input.split(',').map((s) => s.trim()).toList();
        bool hasWindows = false;
        bool hasMacOS = false;
        bool hasLinux = false;
        bool isValid = true;
        
        for (final selection in selections) {
          switch (selection) {
            case '1':
              hasWindows = true;
              print(_colorize('  ✅ Windows added!', Colors.green));
              break;
            case '2':
              hasMacOS = true;
              print(_colorize('  ✅ macOS added!', Colors.green));
              break;
            case '3':
              hasLinux = true;
              print(_colorize('  ✅ Linux added!', Colors.green));
              break;
            default:
              print(_colorize('  ❌ Invalid selection: $selection. Please use 1, 2, or 3.', Colors.red));
              isValid = false;
          }
        }
        
        if (isValid && (hasWindows || hasMacOS || hasLinux)) {
          if (hasWindows && hasMacOS && hasLinux) {
            print(_colorize('  🎉 All desktop platforms selected!', Colors.green));
            return DesktopPlatform.all;
          } else if (hasWindows && !hasMacOS && !hasLinux) {
            print(_colorize('  🎉 Windows only selected!', Colors.green));
            return DesktopPlatform.windows;
          } else if (!hasWindows && hasMacOS && !hasLinux) {
            print(_colorize('  🎉 macOS only selected!', Colors.green));
            return DesktopPlatform.macos;
          } else if (!hasWindows && !hasMacOS && hasLinux) {
            print(_colorize('  🎉 Linux only selected!', Colors.green));
            return DesktopPlatform.linux;
          } else {
            // Custom combination
            print(_colorize('  🎉 Custom desktop combination selected!', Colors.green));
            return DesktopPlatform.custom;
          }
        } else if (!hasWindows && !hasMacOS && !hasLinux) {
          print(_colorize('  ❌ Please select at least one desktop platform.', Colors.red));
        }
      } else {
        print(_colorize('  ❌ Please enter valid selections.', Colors.red));
      }
    }
  }

  bool _promptForCleanArchitecture() {
    print('\n${_colorize('🏗️  Architecture Setup:', Colors.green, bold: true)}\n');
    print(_colorize('  ┌─ Clean Architecture Configuration ─────────────────┐', Colors.cyan));
    print('${_colorize('  │', Colors.cyan)} ${_colorize('Would you like to apply Clean Architecture?', Colors.yellow)}        ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}                                                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('✅ Benefits:', Colors.green)}                                       ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Separation of concerns', Colors.white)}                         ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Testability', Colors.white)}                                   ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Maintainability', Colors.white)}                               ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Scalability', Colors.white)}                                   ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Dependency inversion', Colors.white)}                          ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}                                                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('📁 Will create:', Colors.blue)}                                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• lib/core/ (constants, errors, utils, di)', Colors.white)}       ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• lib/domain/ (entities, repositories, usecases)', Colors.white)} ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• lib/data/ (datasources, repositories, models)', Colors.white)}  ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• lib/presentation/ (pages, widgets, controllers)', Colors.white)} ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Base classes and templates', Colors.white)}                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  └────────────────────────────────────────────────────┘', Colors.cyan)}\n');

    while (true) {
      stdout.write(_colorize('  Apply Clean Architecture? (Y/n): ', Colors.blue));
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

  bool _promptForLinterRules() {
    print('\n${_colorize('🔍 Code Quality Setup:', Colors.green, bold: true)}\n');
    print(_colorize('  ┌─ Linter Rules Configuration ──────────────────────┐', Colors.cyan));
    print('${_colorize('  │', Colors.cyan)} ${_colorize('Would you like to add custom linter rules?', Colors.yellow)}        ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}                                                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('✅ Benefits:', Colors.green)}                                       ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Consistent code style', Colors.white)}                         ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Better code quality', Colors.white)}                           ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Catch potential issues early', Colors.white)}                  ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Team collaboration standards', Colors.white)}                   ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}                                                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('📁 Will create:', Colors.blue)}                                    ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• analysis_options.yaml with custom rules', Colors.white)}       ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Flutter lints configuration', Colors.white)}                   ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)}    ${_colorize('• Code style enforcement', Colors.white)}                        ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  └────────────────────────────────────────────────────┘', Colors.cyan)}\n');

    while (true) {
      stdout.write(_colorize('  Add custom linter rules? (Y/n): ', Colors.blue));
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

  String _getPlatformsDisplay(List<PlatformType> platforms) {
    if (platforms.length == 1) {
      return platforms.first.displayName;
    } else if (platforms.length == 3) {
      return 'All platforms';
    } else {
      return platforms.map((p) => p.shortName).join(', ');
    }
  }

  Future<void> _confirmAndCreateProject(ProjectConfig config) async {
    print('\n${_colorize('📋 Project Configuration Summary:', Colors.green, bold: true)}\n');
    print(_colorize('  ┌─ Configuration ───────────────────────────────────┐', Colors.cyan));
    print('${_colorize('  │', Colors.cyan)} ${_colorize('Project Name:', Colors.yellow)} ${config.projectName.padRight(30)} ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('Organization:', Colors.yellow)} ${config.organizationName.padRight(30)} ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('Platforms:', Colors.yellow)} ${_getPlatformsDisplay(config.platforms).padRight(30)} ${_colorize('│', Colors.cyan)}');
    
    // Only show mobile configuration if mobile platform is selected
    if (config.platforms.contains(PlatformType.mobile)) {
      print('${_colorize('  │', Colors.cyan)} ${_colorize('Mobile Config:', Colors.yellow)} ${config.mobilePlatform.displayName.padRight(25)} ${_colorize('│', Colors.cyan)}');
    }
    
    // Only show desktop configuration if desktop platform is selected
    if (config.platforms.contains(PlatformType.desktop)) {
      print('${_colorize('  │', Colors.cyan)} ${_colorize('Desktop Config:', Colors.yellow)} ${config.desktopPlatform.displayName.padRight(25)} ${_colorize('│', Colors.cyan)}');
    }
    print('${_colorize('  │', Colors.cyan)} ${_colorize('State Management:', Colors.yellow)} ${config.stateManagement.displayName.padRight(25)} ${_colorize('│', Colors.cyan)}');
    if (config.stateManagement == StateManagementType.bloc) {
      print('${_colorize('  │', Colors.cyan)} ${_colorize('Freezed:', Colors.yellow)} ${(config.includeFreezed ? 'Yes' : 'No').padRight(40)} ${_colorize('│', Colors.cyan)}');
    }
    print('${_colorize('  │', Colors.cyan)} ${_colorize('Go Router:', Colors.yellow)} ${(config.includeGoRouter ? 'Yes' : 'No').padRight(35)} ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('Clean Architecture:', Colors.yellow)} ${(config.includeCleanArchitecture ? 'Yes' : 'No').padRight(30)} ${_colorize('│', Colors.cyan)}');
    print('${_colorize('  │', Colors.cyan)} ${_colorize('Linter Rules:', Colors.yellow)} ${(config.includeLinterRules ? 'Yes' : 'No').padRight(35)} ${_colorize('│', Colors.cyan)}');
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
        final version = VersionChecker.getLatestVersion(config.stateManagement == StateManagementType.bloc || config.stateManagement == StateManagementType.cubit ? 'flutter_bloc' : 'provider');
        print(_colorize('  📦 Adding ${config.stateManagement.shortName} dependencies...', Colors.blue));
        print(_colorize('  ✅ ${config.stateManagement.shortName} setup complete! (${VersionChecker.formatVersion(version)})', Colors.green));
      }

      if (config.includeFreezed) {
        print(_colorize('  ❄️  Adding Freezed dependencies...', Colors.cyan));
        print(_colorize('  ✅ Freezed setup complete!', Colors.green));
      }

      if (config.includeGoRouter) {
        final version = VersionChecker.getLatestVersion('go_router');
        print(_colorize('  🗺️  Adding Go Router configuration...', Colors.magenta));
        print(_colorize('  ✅ Go Router setup complete! (${VersionChecker.formatVersion(version)})', Colors.green));
      }

      if (config.includeCleanArchitecture) {
        final version = VersionChecker.getLatestVersion('equatable');
        print(_colorize('  🏗️  Setting up Clean Architecture structure...', Colors.cyan));
        print(_colorize('  ✅ Clean Architecture setup complete! (${VersionChecker.formatVersion(version)})', Colors.green));
      }

      if (config.includeLinterRules) {
        print(_colorize('  🔍 Adding custom linter rules...', Colors.yellow));
        print(_colorize('  ✅ Linter rules setup complete!', Colors.green));
      }

      _printSuccessMessage(config);
      _printNextSteps(config);
      
      if (config.includeFreezed) {
        print('\n${_colorize('  🔧 Freezed Setup:', Colors.cyan, bold: true)}');
        print(_colorize('  ┌─ Next Steps ─────────────────────────────────────────┐', Colors.cyan));
        print('${_colorize('  │', Colors.cyan)} ${_colorize('Run the following command to generate Freezed files:', Colors.yellow)} ${_colorize('│', Colors.cyan)}');
        print('${_colorize('  │', Colors.cyan)} ${_colorize('dart run build_runner build -d', Colors.green, bold: true)}                    ${_colorize('│', Colors.cyan)}');
        print('${_colorize('  └────────────────────────────────────────────────────┘', Colors.cyan)}\n');
      }

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
    if (config.stateManagement == StateManagementType.bloc) {
      print('${_colorize('  │', Colors.green)} ${_colorize('❄️  Freezed:', Colors.yellow)} ${config.includeFreezed ? 'Yes' : 'No'}');
    }
    print('${_colorize('  │', Colors.green)} ${_colorize('🏗️  Clean Architecture:', Colors.yellow)} ${config.includeCleanArchitecture ? 'Yes' : 'No'}');
    print('${_colorize('  │', Colors.green)} ${_colorize('🔍 Linter Rules:', Colors.yellow)} ${config.includeLinterRules ? 'Yes' : 'No'}');
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