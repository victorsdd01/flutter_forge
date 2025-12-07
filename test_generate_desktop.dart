import 'dart:io';
import 'lib/domain/entities/project_config.dart';
import 'lib/data/repositories/project_repository_impl.dart';
import 'lib/data/datasources/file_system_datasource.dart';
import 'lib/data/datasources/flutter_command_datasource.dart';

void main() async {
  final fileSystemDataSource = FileSystemDataSourceImpl();
  final flutterCommandDataSource = FlutterCommandDataSourceImpl();
  final projectRepository = ProjectRepositoryImpl(
    fileSystemDataSource: fileSystemDataSource,
    flutterCommandDataSource: flutterCommandDataSource,
  );

  final projectPath = '/Users/victorsdd/desktop';
  final projectName = 'test_project_${DateTime.now().millisecondsSinceEpoch}';
  
  Directory.current = Directory(projectPath);

  final config = ProjectConfig(
    projectName: projectName,
    organizationName: 'com.test',
    platforms: [PlatformType.mobile],
    stateManagement: StateManagementType.bloc,
    architecture: ArchitectureType.cleanArchitecture,
    includeGoRouter: true,
    includeLinterRules: true,
    includeFreezed: true,
    mobilePlatform: MobilePlatform.both,
    desktopPlatform: DesktopPlatform.all,
  );

  try {
    print('🚀 Generating test project in $projectPath...');
    print('📁 Project name: $projectName');
    await projectRepository.createProject(config);
    print('✅ Project generated successfully!');
    print('📁 Location: $projectPath/$projectName');
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

