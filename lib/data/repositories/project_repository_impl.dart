import '../../domain/entities/project_config.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/file_system_datasource.dart';
import '../datasources/flutter_command_datasource.dart';

/// Implementation of ProjectRepository
class ProjectRepositoryImpl implements ProjectRepository {
  final FileSystemDataSource _fileSystemDataSource;
  final FlutterCommandDataSource _flutterCommandDataSource;

  ProjectRepositoryImpl({
    required FileSystemDataSource fileSystemDataSource,
    required FlutterCommandDataSource flutterCommandDataSource,
  })  : _fileSystemDataSource = fileSystemDataSource,
        _flutterCommandDataSource = flutterCommandDataSource;

  @override
  Future<void> createProject(ProjectConfig config) async {
            // Create Flutter project
        await _flutterCommandDataSource.createFlutterProject(
          projectName: config.projectName,
          organizationName: config.organizationName,
          platforms: config.platforms,
          mobilePlatform: config.mobilePlatform,
          desktopPlatform: config.desktopPlatform,
          customDesktopPlatforms: config.customDesktopPlatforms,
        );

    // Add dependencies (both state management and Go Router if needed)
    await _fileSystemDataSource.addDependencies(
      config.projectName, 
      config.stateManagement, 
      config.includeGoRouter,
      config.includeCleanArchitecture,
      config.includeFreezed
    );

              // Create Clean Architecture structure FIRST if needed
          if (config.includeCleanArchitecture) {
            await _fileSystemDataSource.createCleanArchitectureStructure(
              config.projectName, 
              config.stateManagement,
              includeGoRouter: config.includeGoRouter,
              includeFreezed: config.includeFreezed,
            );
          }

    // Create directory structure (only if not using Clean Architecture)
    if (!config.includeCleanArchitecture) {
      await _fileSystemDataSource.createDirectoryStructure(
        config.projectName, 
        config.stateManagement, 
        config.includeGoRouter
      );
    }

    // Create state management templates if needed
    if (config.stateManagement != StateManagementType.none) {
      await _fileSystemDataSource.createStateManagementTemplates(
        config.projectName, 
        config.stateManagement,
        config.includeFreezed
      );
    }

    // Create Go Router templates if needed
    if (config.includeGoRouter) {
      await _fileSystemDataSource.createGoRouterTemplates(config.projectName);
    }

    // Update main.dart with all configurations
    await _fileSystemDataSource.updateMainFile(
      config.projectName, 
      config.stateManagement, 
      config.includeGoRouter,
      config.includeCleanArchitecture,
      config.includeFreezed
    );

    // Create linter rules if requested
    if (config.includeLinterRules) {
      await _fileSystemDataSource.createLinterRules(config.projectName);
    }

    // Create build.yaml if Freezed is selected
    if (config.includeFreezed) {
      await _fileSystemDataSource.createBuildYaml(config.projectName);
    }

    // Create internationalization setup
    await _fileSystemDataSource.createInternationalization(config.projectName);

    // Generate localization files
    await _flutterCommandDataSource.generateLocalizationFiles(config.projectName);

    // Clean build cache to prevent depfile issues
    await _flutterCommandDataSource.cleanBuildCache(config.projectName);

    // Create barrel files if Clean Architecture is enabled
    if (config.includeCleanArchitecture) {
      await _fileSystemDataSource.createBarrelFiles(
        config.projectName, 
        config.stateManagement, 
        config.includeCleanArchitecture,
        config.includeFreezed
      );
    }
  }

  @override
  Future<void> addStateManagement(String projectName, StateManagementType stateManagement) async {
    // This method is called when only state management is needed (no Go Router)
    // Add dependencies to pubspec.yaml
    await _fileSystemDataSource.addDependencies(projectName, stateManagement, false, false, false);

    // Create directory structure
    await _fileSystemDataSource.createDirectoryStructure(projectName, stateManagement, false);

    // Create state management templates
    await _fileSystemDataSource.createStateManagementTemplates(projectName, stateManagement, false);

    // Update main.dart
    await _fileSystemDataSource.updateMainFile(projectName, stateManagement, false, false, false);
  }

  @override
  Future<void> addGoRouter(String projectName) async {
    // This method is called when Go Router is added to an existing project
    // We need to get the current state management type from the project
    // For now, we'll assume it's none and let the main createProject handle the integration
    
    // Create Go Router templates
    await _fileSystemDataSource.createGoRouterTemplates(projectName);
  }

           @override
         Future<void> addCleanArchitecture(String projectName) async {
           // This method is called when Clean Architecture is added to an existing project
           // For now, we'll assume no state management when adding CA to existing project
           await _fileSystemDataSource.createCleanArchitectureStructure(projectName, StateManagementType.none, includeFreezed: false);
         }

  @override
  Future<bool> isFlutterInstalled() async {
    return await _flutterCommandDataSource.isFlutterInstalled();
  }
} 