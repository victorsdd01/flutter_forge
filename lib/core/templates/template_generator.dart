import 'dart:io';

class TemplateGenerator {
  static final TemplateGenerator _instance = TemplateGenerator._();
  TemplateGenerator._();
  static TemplateGenerator get instance => _instance;

  Future<void> generateProjectTemplates({
    required String projectName,
    required String projectPath,
  }) async {
    final templatePath = 'lib/core/templates/blocs';
    await _copyTemplates(templatePath, projectPath, projectName);
  }

  /// Copies templates from source to destination with name replacement
  Future<void> _copyTemplates(
    String sourcePath,
    String destinationPath,
    String projectName,
  ) async {
    final sourceDir = Directory(sourcePath);
    if (!await sourceDir.exists()) {
      throw Exception('Template directory not found: $sourcePath');
    }

    await _copyDirectoryRecursively(sourceDir, Directory(destinationPath), projectName);
  }

  /// Recursively copies directory structure with template variable replacement
  Future<void> _copyDirectoryRecursively(
    Directory source,
    Directory destination,
    String projectName,
  ) async {
    if (!await destination.exists()) {
      await destination.create(recursive: true);
    }

    await for (final entity in source.list()) {
      final fileName = entity.path.split('/').last;
      final destinationPath = '${destination.path}/$fileName';

      if (entity is File) {
        final content = await File(entity.path).readAsString();
        final processedContent = _processTemplate(content, projectName);
        await File(destinationPath).writeAsString(processedContent);
      } else if (entity is Directory) {
        await _copyDirectoryRecursively(
          entity,
          Directory(destinationPath),
          projectName,
        );
      }
    }
  }

  /// Processes template variables in content
  String _processTemplate(String content, String projectName) {
    return content.replaceAll('{{project_name}}', projectName);
  }
}