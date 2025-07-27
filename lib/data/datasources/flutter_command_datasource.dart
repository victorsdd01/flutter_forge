import 'dart:io';

/// Data source for Flutter command operations
abstract class FlutterCommandDataSource {
  Future<void> createFlutterProject({
    required String projectName,
    required String organizationName,
  });
  
  Future<bool> isFlutterInstalled();
}

/// Implementation of FlutterCommandDataSource
class FlutterCommandDataSourceImpl implements FlutterCommandDataSource {
  @override
  Future<void> createFlutterProject({
    required String projectName,
    required String organizationName,
  }) async {
    final result = await Process.run(
      'flutter',
      ['create', '--org', organizationName, projectName],
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
}

/// Exception thrown when Flutter command fails
class FlutterCommandException implements Exception {
  final String message;
  FlutterCommandException(this.message);

  @override
  String toString() => 'FlutterCommandException: $message';
} 