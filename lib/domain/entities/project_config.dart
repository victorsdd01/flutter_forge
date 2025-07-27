/// Represents the configuration for a Flutter project
class ProjectConfig {
  final String projectName;
  final String organizationName;
  final StateManagementType stateManagement;
  final bool includeGoRouter;

  const ProjectConfig({
    required this.projectName,
    required this.organizationName,
    required this.stateManagement,
    this.includeGoRouter = false,
  });

  /// Validates the project configuration
  bool get isValid {
    return isValidProjectName(projectName) && 
           isValidOrganizationName(organizationName);
  }

  /// Validates project name format
  static bool isValidProjectName(String name) {
    return RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name);
  }

  /// Validates organization name format
  static bool isValidOrganizationName(String name) {
    return RegExp(r'^[a-z][a-z0-9.]*[a-z0-9]$').hasMatch(name);
  }

  @override
  String toString() {
    return 'ProjectConfig(projectName: $projectName, organizationName: $organizationName, stateManagement: $stateManagement, includeGoRouter: $includeGoRouter)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectConfig &&
        other.projectName == projectName &&
        other.organizationName == organizationName &&
        other.stateManagement == stateManagement &&
        other.includeGoRouter == includeGoRouter;
  }

  @override
  int get hashCode {
    return projectName.hashCode ^
        organizationName.hashCode ^
        stateManagement.hashCode ^
        includeGoRouter.hashCode;
  }
}

/// Enum representing different state management types
enum StateManagementType {
  bloc,
  cubit,
  provider,
  none;

  String get displayName {
    switch (this) {
      case StateManagementType.bloc:
        return 'BLoC (Business Logic Component)';
      case StateManagementType.cubit:
        return 'Cubit (Simplified BLoC)';
      case StateManagementType.provider:
        return 'Provider';
      case StateManagementType.none:
        return 'None (Basic Flutter project)';
    }
  }

  String get shortName {
    switch (this) {
      case StateManagementType.bloc:
        return 'bloc';
      case StateManagementType.cubit:
        return 'cubit';
      case StateManagementType.provider:
        return 'provider';
      case StateManagementType.none:
        return 'none';
    }
  }
} 