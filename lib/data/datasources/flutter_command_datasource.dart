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
  
  Future<void> runBuildRunner(String projectName);
  
  Future<void> setupCocoaPods(String projectName, List<PlatformType> platforms);
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
        
        // Replace the wrong import with the correct one
        content = content.replaceFirst(
          "import 'package:flutter_gen/gen_l10n/app_localizations.dart';",
          "import '../l10n.dart';"
        );
        
        appLocalizationsFile.writeAsStringSync(content);
      }
    } catch (e) {
      // Silently handle the error - this is not critical for the user experience
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

  @override
  Future<void> runBuildRunner(String projectName) async {
    const String reset = '\x1B[0m';
    const String bold = '\x1B[1m';
    const String brightCyan = '\x1B[96m';
    const String dim = '\x1B[2m';
    
    try {
      print('');
      print('$brightCyan$bold⏳ Please wait, we are setting up your project...$reset');
      print('$dim   This may take a few moments$reset');
      print('');
      
      final result = await Process.run(
        'dart',
        ['run', 'build_runner', 'build', '-d'],
        workingDirectory: projectName,
      );

      if (result.exitCode == 0) {
        // Success message will be shown in cli_controller after this completes
      } else {
        print('\n⚠️  Warning: build_runner completed with errors.');
        print('   You may need to run "dart run build_runner build -d" manually.\n');
      }
    } catch (e) {
      print('\n⚠️  Warning: Failed to run build_runner: $e');
      print('   You may need to run "dart run build_runner build -d" manually.\n');
    }
  }

  @override
  Future<void> setupCocoaPods(String projectName, List<PlatformType> platforms) async {
    // Check if iOS or macOS directories exist (Flutter creates them based on platform selection)
    final bool hasIOS = platforms.contains(PlatformType.mobile) && 
                        Directory('$projectName/ios').existsSync();
    final bool hasMacOS = platforms.contains(PlatformType.desktop) && 
                          Directory('$projectName/macos').existsSync();
    
    if (!hasIOS && !hasMacOS) {
      return; // Skip if no iOS or macOS directories
    }

    const String reset = '\x1B[0m';
    const String bold = '\x1B[1m';
    const String brightCyan = '\x1B[96m';
    const String dim = '\x1B[2m';
    
    try {
      // Check if pod command exists
      final podCheck = await Process.run('which', ['pod']);
      if (podCheck.exitCode != 0) {
        print('\n⚠️  Warning: CocoaPods is not installed.');
        print('   iOS/macOS projects may not compile until you run:');
        print('   cd $projectName/ios && rm -rf Pods Podfile.lock && pod repo update && pod install');
        if (hasMacOS) {
          print('   cd $projectName/macos && rm -rf Pods Podfile.lock && pod repo update && pod install');
        }
        print('');
        return;
      }

      print('');
      print('$brightCyan$bold📦 Setting up CocoaPods for iOS/macOS...$reset');
      print('$dim   This may take a few moments$reset');
      print('');

      // Setup iOS CocoaPods
      if (hasIOS) {
        final iosDir = Directory('$projectName/ios');
        if (iosDir.existsSync()) {
          // Remove existing Pods and Podfile.lock
          final podsDir = Directory('$projectName/ios/Pods');
          final podfileLock = File('$projectName/ios/Podfile.lock');
          
          if (podsDir.existsSync()) {
            await podsDir.delete(recursive: true);
          }
          if (podfileLock.existsSync()) {
            await podfileLock.delete();
          }

          // Run pod repo update
          print('$dim   Updating CocoaPods repository...$reset');
          await Process.run(
            'pod',
            ['repo', 'update'],
            workingDirectory: '$projectName/ios',
          );

          // Run pod install
          print('$dim   Installing CocoaPods dependencies...$reset');
          final podInstallResult = await Process.run(
            'pod',
            ['install', '--repo-update'],
            workingDirectory: '$projectName/ios',
          );

          if (podInstallResult.exitCode == 0) {
            print('$brightCyan   ✅ iOS CocoaPods setup completed$reset');
          } else {
            print('   ⚠️  Warning: iOS pod install completed with errors.');
            print('   You may need to run "cd $projectName/ios && pod install" manually.');
          }
        }
      }

      // Setup macOS CocoaPods
      if (hasMacOS) {
        final macosDir = Directory('$projectName/macos');
        if (macosDir.existsSync()) {
          // Remove existing Pods and Podfile.lock
          final podsDir = Directory('$projectName/macos/Pods');
          final podfileLock = File('$projectName/macos/Podfile.lock');
          
          if (podsDir.existsSync()) {
            await podsDir.delete(recursive: true);
          }
          if (podfileLock.existsSync()) {
            await podfileLock.delete();
          }

          // Run pod repo update
          print('$dim   Updating CocoaPods repository for macOS...$reset');
          await Process.run(
            'pod',
            ['repo', 'update'],
            workingDirectory: '$projectName/macos',
          );

          // Run pod install
          print('$dim   Installing CocoaPods dependencies for macOS...$reset');
          final podInstallResult = await Process.run(
            'pod',
            ['install', '--repo-update'],
            workingDirectory: '$projectName/macos',
          );

          if (podInstallResult.exitCode == 0) {
            print('$brightCyan   ✅ macOS CocoaPods setup completed$reset');
          } else {
            print('   ⚠️  Warning: macOS pod install completed with errors.');
            print('   You may need to run "cd $projectName/macos && pod install" manually.');
          }
        }
      }

      print('');
    } catch (e) {
      print('\n⚠️  Warning: Failed to setup CocoaPods: $e');
      print('   You may need to run the following commands manually:');
      if (hasIOS) {
        print('   cd $projectName/ios && rm -rf Pods Podfile.lock && pod repo update && pod install');
      }
      if (hasMacOS) {
        print('   cd $projectName/macos && rm -rf Pods Podfile.lock && pod repo update && pod install');
      }
      print('');
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