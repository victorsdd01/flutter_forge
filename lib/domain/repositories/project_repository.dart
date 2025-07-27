import '../entities/project_config.dart';

/// Repository interface for project creation operations
abstract class ProjectRepository {
  /// Creates a Flutter project with the given configuration
  Future<void> createProject(ProjectConfig config);
  
  /// Adds state management dependencies and templates to the project
  Future<void> addStateManagement(String projectName, StateManagementType stateManagement);
  
  /// Adds Go Router dependencies and templates to the project
  Future<void> addGoRouter(String projectName);
  
  /// Adds Clean Architecture structure and dependencies to the project
  Future<void> addCleanArchitecture(String projectName);
  
  /// Validates if Flutter is installed and available
  Future<bool> isFlutterInstalled();
} 