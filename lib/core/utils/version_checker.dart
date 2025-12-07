import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Utility class to check for the latest versions of Flutter packages
class VersionChecker {
  static const Map<String, String> _latestVersions = {
    'flutter_bloc': '^9.1.1',
    'hydrated_bloc': '^10.1.1',
    'replay_bloc': '^0.3.0',
    'bloc_concurrency': '^0.3.0',
    'dartz': '^0.10.1',
    'path_provider': '^2.1.5',
    'get_it': '^8.0.3',
    'provider': '^6.1.5',
    'go_router': '^16.0.0',
    'equatable': '^2.0.7',
  };

  static const String _githubApiUrl = 'https://api.github.com/repos/victorsdd01/flutter_forge/releases/latest';
  
  /// Get current version from pubspec.yaml
  static String getCurrentVersion() {
    try {
      final pubspecPath = _findPubspecPath();
      if (pubspecPath == null) {
        return '1.0.0';
      }
      
      final file = File(pubspecPath);
      if (!file.existsSync()) {
        return '1.0.0';
      }
      
      final content = file.readAsStringSync();
      final versionMatch = RegExp(r'version:\s*(\d+\.\d+\.\d+)').firstMatch(content);
      if (versionMatch != null) {
        return versionMatch.group(1)!;
      }
    } catch (e) {
      // Fallback to default version
    }
    
    return '1.0.0';
  }
  
  /// Find pubspec.yaml path (works when installed globally or locally)
  static String? _findPubspecPath() {
    try {
      final scriptPath = Platform.script.toFilePath();
      final scriptDir = path.dirname(scriptPath);
      final scriptDirNormalized = path.normalize(scriptDir);
      
      final possiblePaths = <String>[
        path.join(scriptDirNormalized, 'pubspec.yaml'),
        path.join(scriptDirNormalized, '..', 'pubspec.yaml'),
        path.join(scriptDirNormalized, '..', '..', 'pubspec.yaml'),
        path.join(scriptDirNormalized, '..', '..', '..', 'pubspec.yaml'),
        path.join(scriptDirNormalized, '..', '..', '..', '..', 'pubspec.yaml'),
        path.join(scriptDirNormalized, '..', '..', '..', '..', '..', 'pubspec.yaml'),
        path.join(Directory.current.path, 'pubspec.yaml'),
      ];
      
      for (final possiblePath in possiblePaths) {
        final normalizedPath = path.normalize(possiblePath);
        final file = File(normalizedPath);
        if (file.existsSync()) {
          return normalizedPath;
        }
      }
    } catch (e) {
      // Try alternative method
    }
    
    final currentDirPubspec = File(path.join(Directory.current.path, 'pubspec.yaml'));
    if (currentDirPubspec.existsSync()) {
      return currentDirPubspec.path;
    }
    
    return null;
  }
  
  /// Get the latest version for a specific package
  static String getLatestVersion(String packageName) {
    return _latestVersions[packageName] ?? '^1.0.0';
  }

  /// Get all latest versions
  static Map<String, String> getAllLatestVersions() {
    return Map.from(_latestVersions);
  }

  /// Check if a version is the latest
  static bool isLatestVersion(String packageName, String currentVersion) {
    final latest = getLatestVersion(packageName);
    return currentVersion == latest;
  }

  /// Get version recommendations for packages
  static Map<String, String> getVersionRecommendations() {
    return _latestVersions;
  }

  /// Format version for display
  static String formatVersion(String version) {
    return version.replaceAll('^', '');
  }

  /// Get a summary of all latest versions
  static String getVersionSummary() {
    final summary = StringBuffer();
    summary.writeln('📦 Latest Package Versions:');
    summary.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    
    _latestVersions.forEach((package, version) {
      summary.writeln('  ${package.padRight(15)} ${formatVersion(version)}');
    });
    
    return summary.toString();
  }

  /// Get the latest CLI version from GitHub releases
  static Future<String?> getLatestCLIVersion() async {
    try {
      final response = await http.get(Uri.parse(_githubApiUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tagName = data['tag_name']?.toString();
        if (tagName != null) {
          return tagName.replaceFirst('v', '');
        }
      }
    } catch (e) {
      // Silently fail - network issues shouldn't break the CLI
    }
    
    return null;
  }
  
  /// Get the latest CLI version from Git (fallback if no releases)
  static Future<String?> getLatestCLIVersionFromGit() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/victorsdd01/flutter_forge/contents/pubspec.yaml'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['content'] as String?;
        if (content != null) {
          final decodedContent = utf8.decode(base64Decode(content));
          final versionMatch = RegExp(r'version:\s*(\d+\.\d+\.\d+)').firstMatch(decodedContent);
          if (versionMatch != null) {
            return versionMatch.group(1)!;
          }
        }
      }
    } catch (e) {
      // Silently fail
    }
    
    return null;
  }
  
  /// Get the latest CLI version (tries releases first, then Git)
  static Future<String?> getLatestCLIVersionAny() async {
    final releaseVersion = await getLatestCLIVersion();
    if (releaseVersion != null) {
      return releaseVersion;
    }
    
    return await getLatestCLIVersionFromGit();
  }
  
  /// Check if an update is available
  static Future<bool> isUpdateAvailable(String currentVersion) async {
    final latestVersion = await getLatestCLIVersion();
    if (latestVersion == null) return false;
    
    return compareVersions(currentVersion, latestVersion) < 0;
  }
  
  /// Compare two version strings
  /// Returns: -1 if version1 < version2, 0 if equal, 1 if version1 > version2
  static int compareVersions(String version1, String version2) {
    final parts1 = version1.split('.').map(int.parse).toList();
    final parts2 = version2.split('.').map(int.parse).toList();
    
    // Pad with zeros if needed
    while (parts1.length < parts2.length) {
      parts1.add(0);
    }
    while (parts2.length < parts1.length) {
      parts2.add(0);
    }
    
    for (int i = 0; i < parts1.length; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }
    
    return 0;
  }
} 