import 'dart:io';
import 'package:path/path.dart' as path;
import 'template_contents.dart';

class TemplateGenerator {
  static final TemplateGenerator _instance = TemplateGenerator._();
  TemplateGenerator._();
  static TemplateGenerator get instance => _instance;

  Future<void> generateProjectTemplates({
    required String projectName,
    required String projectPath,
  }) async {
    final templates = TemplateContents.getProcessedTemplates(projectName);
    final libPath = '$projectPath/lib';
    
    for (final entry in templates.entries) {
      final relativePath = entry.key;
      final content = entry.value;
      final filePath = path.join(libPath, relativePath);
      final file = File(filePath);
      
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
    }
  }
}