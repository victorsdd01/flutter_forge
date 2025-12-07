import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as path;

class TemplateGenerator {
  static final TemplateGenerator _instance = TemplateGenerator._();
  TemplateGenerator._();
  static TemplateGenerator get instance => _instance;

  String? _packageRootPath;

  Future<String> _getPackageRootPath() async {
    if (_packageRootPath != null) {
      return _packageRootPath!;
    }

    try {
      final packageUri = await Isolate.resolvePackageUri(Uri.parse('package:flutterforge/core/templates/template_generator.dart'));
      if (packageUri != null) {
        final packagePath = packageUri.toFilePath();
        final libDir = Directory(path.dirname(packagePath));
        final packageRoot = libDir.parent;
        
        final templatesDir = Directory(path.join(packageRoot.path, 'lib', 'core', 'templates', 'blocs'));
        if (templatesDir.existsSync()) {
          _packageRootPath = packageRoot.path;
          return _packageRootPath!;
        }
      }
    } catch (e) {
    }

    final scriptPath = Platform.script.toFilePath();
    final scriptDir = Directory(path.dirname(scriptPath)).absolute;
    
    Directory currentDir = scriptDir;
    
    while (currentDir.path != currentDir.parent.path) {
      final libDir = Directory(path.join(currentDir.path, 'lib'));
      final templatesDir = Directory(path.join(libDir.path, 'core', 'templates', 'blocs'));
      
      if (templatesDir.existsSync()) {
        _packageRootPath = currentDir.path;
        return _packageRootPath!;
      }
      
      currentDir = currentDir.parent;
    }
    
    throw Exception('Could not find package root. Templates directory not found.');
  }

  Future<void> generateProjectTemplates({
    required String projectName,
    required String projectPath,
  }) async {
    final packageRoot = await _getPackageRootPath();
    final templatePath = path.join(packageRoot, 'lib', 'core', 'templates', 'blocs');
    final libPath = '$projectPath/lib';
    await _copyTemplates(templatePath, libPath, projectName);
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
      
      if (fileName == 'pubspec.yaml' || fileName == 'pubspec.lock' || fileName == 'README.md' || fileName == 'build') {
        continue;
      }
      
      final destinationPath = '${destination.path}/$fileName';

      if (entity is File) {
        final content = await File(entity.path).readAsString();
        final processedContent = _processTemplate(content, projectName);
        final destinationFile = File(destinationPath);
        if (await destinationFile.exists()) {
          await destinationFile.delete();
        }
        await destinationFile.writeAsString(processedContent);
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
    return content
        .replaceAll('{{project_name}}', projectName)
        .replaceAll('template_project', projectName);
  }
}