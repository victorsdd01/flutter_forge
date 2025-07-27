import '../entities/project_config.dart';

/// Use case for validating project configuration
class ValidateProjectConfigUseCase {
  /// Validates the project configuration and returns validation errors
  List<String> execute(ProjectConfig config) {
    final errors = <String>[];

    // Validate project name
    if (config.projectName.isEmpty) {
      errors.add('Project name cannot be empty');
    } else if (!ProjectConfig.isValidProjectName(config.projectName)) {
      errors.add('Invalid project name. Use lowercase letters, numbers, and underscores only.');
    }

    // Validate organization name
    if (config.organizationName.isEmpty) {
      errors.add('Organization name cannot be empty');
    } else if (!ProjectConfig.isValidOrganizationName(config.organizationName)) {
      errors.add('Invalid organization name. Use lowercase letters, numbers, and dots only.');
    }

    return errors;
  }

  /// Validates project name format
  bool isValidProjectName(String name) {
    return ProjectConfig.isValidProjectName(name);
  }

  /// Validates organization name format
  bool isValidOrganizationName(String name) {
    return ProjectConfig.isValidOrganizationName(name);
  }
} 