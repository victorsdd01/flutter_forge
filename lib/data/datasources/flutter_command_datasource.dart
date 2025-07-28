import 'dart:io';
import '../../domain/entities/project_config.dart';

/// Data source for Flutter command operations
abstract class FlutterCommandDataSource {
  Future<void> createFlutterProject({
    required String projectName,
    required String organizationName,
    required List<PlatformType> platforms,
    required MobilePlatform mobilePlatform,
    required DesktopPlatform desktopPlatform,
    CustomDesktopPlatforms? customDesktopPlatforms,
  });
  
  Future<bool> isFlutterInstalled();
  
  Future<void> generateLocalizationFiles(String projectName);
  
  Future<void> cleanBuildCache(String projectName);
}

/// Implementation of FlutterCommandDataSource
class FlutterCommandDataSourceImpl implements FlutterCommandDataSource {
  @override
  Future<void> createFlutterProject({
    required String projectName,
    required String organizationName,
    required List<PlatformType> platforms,
    required MobilePlatform mobilePlatform,
    required DesktopPlatform desktopPlatform,
    CustomDesktopPlatforms? customDesktopPlatforms,
  }) async {
    final args = ['create', '--org', organizationName];
    
    // Add platform-specific flags
    if (platforms.contains(PlatformType.web)) {
      args.add('--platforms=web');
    }
    
    if (platforms.contains(PlatformType.desktop)) {
      final desktopPlatforms = <String>[];
      
      if (desktopPlatform == DesktopPlatform.custom && customDesktopPlatforms != null) {
        // Use custom desktop platform selections
        if (customDesktopPlatforms.windows) desktopPlatforms.add('windows');
        if (customDesktopPlatforms.macos) desktopPlatforms.add('macos');
        if (customDesktopPlatforms.linux) desktopPlatforms.add('linux');
      } else {
        // Use predefined desktop platform selections
        if (desktopPlatform == DesktopPlatform.windows || desktopPlatform == DesktopPlatform.all) {
          desktopPlatforms.add('windows');
        }
        if (desktopPlatform == DesktopPlatform.macos || desktopPlatform == DesktopPlatform.all) {
          desktopPlatforms.add('macos');
        }
        if (desktopPlatform == DesktopPlatform.linux || desktopPlatform == DesktopPlatform.all) {
          desktopPlatforms.add('linux');
        }
      }
      
      if (desktopPlatforms.isNotEmpty) {
        args.add('--platforms=${desktopPlatforms.join(',')}');
      }
    }
    
    if (platforms.contains(PlatformType.mobile)) {
      final mobilePlatforms = <String>[];
      if (mobilePlatform == MobilePlatform.android || mobilePlatform == MobilePlatform.both) {
        mobilePlatforms.add('android');
      }
      if (mobilePlatform == MobilePlatform.ios || mobilePlatform == MobilePlatform.both) {
        mobilePlatforms.add('ios');
      }
      if (mobilePlatforms.isNotEmpty) {
        args.add('--platforms=${mobilePlatforms.join(',')}');
      }
    }
    
    args.add(projectName);
    
    final result = await Process.run(
      'flutter',
      args,
      workingDirectory: Directory.current.path,
    );

    if (result.exitCode != 0) {
      throw FlutterCommandException(
        'Failed to create Flutter project: ${result.stderr}',
      );
    }
  }

  @override
  Future<bool> isFlutterInstalled() async {
    try {
      final result = await Process.run('flutter', ['--version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> generateLocalizationFiles(String projectName) async {
    try {
      // Always run intl_utils:generate directly since it's more reliable
      final result = await Process.run(
        'dart',
        ['run', 'intl_utils:generate'],
        workingDirectory: projectName,
      );

      if (result.exitCode != 0) {
        print('Warning: Failed to generate localization files. You may need to run "dart run intl_utils:generate" manually.');
      }

      // Always fix the import in app_localizations.dart after generation
      await _fixAppLocalizationsImport(projectName);
    } catch (e) {
      print('Warning: Failed to generate localization files: $e');
    }
  }

  Future<void> _fixAppLocalizationsImport(String projectName) async {
    try {
      final appLocalizationsFile = File('$projectName/lib/application/generated/l10n/app_localizations.dart');
      if (appLocalizationsFile.existsSync()) {
        String content = appLocalizationsFile.readAsStringSync();
        print('Fixing app_localizations.dart import...');
        print('Original content contains flutter_gen import: ${content.contains("package:flutter_gen/gen_l10n/app_localizations.dart")}');
        
        // Replace the wrong import with the correct one
        content = content.replaceFirst(
          "import 'package:flutter_gen/gen_l10n/app_localizations.dart';",
          "import '../l10n.dart';"
        );
        
        print('After replacement contains correct import: ${content.contains("../l10n.dart")}');
        appLocalizationsFile.writeAsStringSync(content);
        print('Import fix completed successfully!');
      } else {
        print('Warning: app_localizations.dart file not found at expected location');
      }
    } catch (e) {
      print('Warning: Failed to fix app_localizations.dart import: $e');
    }
  }

  @override
  Future<void> cleanBuildCache(String projectName) async {
    try {
      // Run flutter clean to clear build cache
      final result = await Process.run(
        'flutter',
        ['clean'],
        workingDirectory: projectName,
      );

      if (result.exitCode == 0) {
        // Run flutter pub get to restore dependencies
        await Process.run(
          'flutter',
          ['pub', 'get'],
          workingDirectory: projectName,
        );
      }
    } catch (e) {
      print('Warning: Failed to clean build cache: $e');
    }
  }
}

/// Exception thrown when Flutter command fails
class FlutterCommandException implements Exception {
  final String message;
  FlutterCommandException(this.message);

  @override
  String toString() => 'FlutterCommandException: $message';
} 