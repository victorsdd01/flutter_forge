/// Represents the configuration for a Flutter project
class ProjectConfig {
  final String projectName;
  final String organizationName;
  final StateManagementType stateManagement;
  final bool includeGoRouter;
  final bool includeCleanArchitecture;
  final bool includeLinterRules;
  final bool includeFreezed;
  final List<PlatformType> platforms;
  final MobilePlatform mobilePlatform;
  final DesktopPlatform desktopPlatform;
  final CustomDesktopPlatforms? customDesktopPlatforms;

  const ProjectConfig({
    required this.projectName,
    required this.organizationName,
    required this.stateManagement,
    this.includeGoRouter = false,
    this.includeCleanArchitecture = false,
    this.includeLinterRules = false,
    this.includeFreezed = false,
    this.platforms = const [PlatformType.mobile],
    this.mobilePlatform = MobilePlatform.both,
    this.desktopPlatform = DesktopPlatform.all,
    this.customDesktopPlatforms,
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
    return 'ProjectConfig(projectName: $projectName, organizationName: $organizationName, stateManagement: $stateManagement, includeGoRouter: $includeGoRouter, includeCleanArchitecture: $includeCleanArchitecture, includeLinterRules: $includeLinterRules, includeFreezed: $includeFreezed, platforms: $platforms, mobilePlatform: $mobilePlatform, desktopPlatform: $desktopPlatform, customDesktopPlatforms: $customDesktopPlatforms)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectConfig &&
        other.projectName == projectName &&
        other.organizationName == organizationName &&
        other.stateManagement == stateManagement &&
        other.includeGoRouter == includeGoRouter &&
        other.includeCleanArchitecture == includeCleanArchitecture &&
        other.includeLinterRules == includeLinterRules &&
        other.includeFreezed == includeFreezed &&
        other.platforms == platforms &&
        other.mobilePlatform == mobilePlatform &&
        other.desktopPlatform == desktopPlatform &&
        other.customDesktopPlatforms == customDesktopPlatforms;
  }

  @override
  int get hashCode {
    return projectName.hashCode ^
        organizationName.hashCode ^
        stateManagement.hashCode ^
        includeGoRouter.hashCode ^
        includeCleanArchitecture.hashCode ^
        includeLinterRules.hashCode ^
        includeFreezed.hashCode ^
        platforms.hashCode ^
        mobilePlatform.hashCode ^
        desktopPlatform.hashCode ^
        customDesktopPlatforms.hashCode;
  }
}

/// Enum representing different platform types
enum PlatformType {
  mobile,
  web,
  desktop;

  String get displayName {
    switch (this) {
      case PlatformType.mobile:
        return 'Mobile (Android & iOS)';
      case PlatformType.web:
        return 'Web';
      case PlatformType.desktop:
        return 'Desktop (Windows, macOS, Linux)';
    }
  }

  String get shortName {
    switch (this) {
      case PlatformType.mobile:
        return 'mobile';
      case PlatformType.web:
        return 'web';
      case PlatformType.desktop:
        return 'desktop';
    }
  }
}

/// Enum representing different mobile platforms
enum MobilePlatform {
  android,
  ios,
  both;

  String get displayName {
    switch (this) {
      case MobilePlatform.android:
        return 'Android only';
      case MobilePlatform.ios:
        return 'iOS only';
      case MobilePlatform.both:
        return 'Both Android & iOS';
    }
  }
}

/// Enum representing different desktop platforms
enum DesktopPlatform {
  windows,
  macos,
  linux,
  all,
  custom;

  String get displayName {
    switch (this) {
      case DesktopPlatform.windows:
        return 'Windows only';
      case DesktopPlatform.macos:
        return 'macOS only';
      case DesktopPlatform.linux:
        return 'Linux only';
      case DesktopPlatform.all:
        return 'All platforms (Windows, macOS, Linux)';
      case DesktopPlatform.custom:
        return 'Custom selection';
    }
  }
}

/// Class to hold custom desktop platform selections
class CustomDesktopPlatforms {
  final bool windows;
  final bool macos;
  final bool linux;

  const CustomDesktopPlatforms({
    required this.windows,
    required this.macos,
    required this.linux,
  });

  bool get hasAny => windows || macos || linux;
  
  List<String> get platformList {
    final platforms = <String>[];
    if (windows) platforms.add('windows');
    if (macos) platforms.add('macos');
    if (linux) platforms.add('linux');
    return platforms;
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