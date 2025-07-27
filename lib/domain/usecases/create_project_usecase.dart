import '../entities/project_config.dart';
import '../repositories/project_repository.dart';

/// Use case for creating a Flutter project
class CreateProjectUseCase {
  final ProjectRepository _repository;

  CreateProjectUseCase(this._repository);

  /// Executes the project creation process
  Future<void> execute(ProjectConfig config) async {
    // Validate configuration
    if (!config.isValid) {
      throw InvalidProjectConfigException('Invalid project configuration');
    }

    // Check if Flutter is installed
    final isFlutterInstalled = await _repository.isFlutterInstalled();
    if (!isFlutterInstalled) {
      throw FlutterNotInstalledException('Flutter is not installed or not available in PATH');
    }

    // Create the project with all configurations
    await _repository.createProject(config);
  }
}

/// Exception thrown when project configuration is invalid
class InvalidProjectConfigException implements Exception {
  final String message;
  InvalidProjectConfigException(this.message);

  @override
  String toString() => 'InvalidProjectConfigException: $message';
}

/// Exception thrown when Flutter is not installed
class FlutterNotInstalledException implements Exception {
  final String message;
  FlutterNotInstalledException(this.message);

  @override
  String toString() => 'FlutterNotInstalledException: $message';
} 