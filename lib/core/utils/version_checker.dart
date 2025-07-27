import 'dart:convert';
import 'package:http/http.dart' as http;

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
        return data['tag_name']?.toString().replaceFirst('v', '');
      }
    } catch (e) {
      // Silently fail - network issues shouldn't break the CLI
    }
    
    return null;
  }
  
  /// Check if an update is available
  static Future<bool> isUpdateAvailable(String currentVersion) async {
    final latestVersion = await getLatestCLIVersion();
    if (latestVersion == null) return false;
    
    return _compareVersions(currentVersion, latestVersion) < 0;
  }
  
  /// Compare two version strings
  static int _compareVersions(String version1, String version2) {
    final parts1 = version1.split('.').map(int.parse).toList();
    final parts2 = version2.split('.').map(int.parse).toList();
    
    // Pad with zeros if needed
    while (parts1.length < parts2.length) parts1.add(0);
    while (parts2.length < parts1.length) parts2.add(0);
    
    for (int i = 0; i < parts1.length; i++) {
      if (parts1[i] < parts2[i]) return -1;
      if (parts1[i] > parts2[i]) return 1;
    }
    
    return 0;
  }
} 