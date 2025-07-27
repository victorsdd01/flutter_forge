import '../../data/datasources/file_system_datasource.dart';
import '../../data/datasources/flutter_command_datasource.dart';
import '../../data/repositories/project_repository_impl.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/usecases/create_project_usecase.dart';
import '../../domain/usecases/validate_project_config_usecase.dart';
import '../../presentation/controllers/cli_controller.dart';

/// Dependency injection container
class DependencyInjection {
  static DependencyInjection? _instance;
  static DependencyInjection get instance {
    _instance ??= DependencyInjection._();
    return _instance!;
  }

  DependencyInjection._();

  static void initialize() {
    _instance = DependencyInjection._();
  }

  static void reset() {
    _instance = null;
  }

  // Data Sources
  FileSystemDataSource get fileSystemDataSource => FileSystemDataSourceImpl();
  FlutterCommandDataSource get flutterCommandDataSource => FlutterCommandDataSourceImpl();

  // Repositories
  ProjectRepository get projectRepository => ProjectRepositoryImpl(
        fileSystemDataSource: fileSystemDataSource,
        flutterCommandDataSource: flutterCommandDataSource,
      );

  // Use Cases
  CreateProjectUseCase get createProjectUseCase => CreateProjectUseCase(projectRepository);
  ValidateProjectConfigUseCase get validateProjectConfigUseCase => ValidateProjectConfigUseCase();

  // Controllers
  CLIController get cliController => CLIController(
        createProjectUseCase: createProjectUseCase,
        validateProjectConfigUseCase: validateProjectConfigUseCase,
      );
} 