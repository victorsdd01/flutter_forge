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
  final projectName = 'test_auth_project';
  
  print('📁 Working directory: ${Directory.current.path}');
  print('📁 Target path: $projectPath');
  print('📁 Project name: $projectName');
  print('');
  
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
    print('🚀 Generating project...');
    print('📋 Config:');
    print('   - Name: ${config.projectName}');
    print('   - Organization: ${config.organizationName}');
    print('   - Platforms: ${config.platforms}');
    print('   - Architecture: ${config.architecture}');
    print('   - State Management: ${config.stateManagement}');
    print('');
    
    await projectRepository.createProject(config);
    
    print('');
    print('✅ Project generated successfully!');
    print('📁 Location: $projectPath/$projectName');
    
    final projectDir = Directory('$projectPath/$projectName');
    if (await projectDir.exists()) {
      print('✅ Project directory exists');
      final libDir = Directory('$projectPath/$projectName/lib');
      if (await libDir.exists()) {
        print('✅ lib directory exists');
        final authDir = Directory('$projectPath/$projectName/lib/features/auth');
        if (await authDir.exists()) {
          print('✅ Auth feature directory exists');
        } else {
          print('⚠️  Auth feature directory NOT found');
        }
        final dbFile = File('$projectPath/$projectName/lib/core/database/app_database.dart');
        if (await dbFile.exists()) {
          print('✅ Database file exists');
        } else {
          print('⚠️  Database file NOT found');
        }
      } else {
        print('⚠️  lib directory NOT found');
      }
    } else {
      print('❌ Project directory NOT found!');
    }
  } catch (e, stackTrace) {
    print('');
    print('❌ Error: $e');
    print('');
    print('Stack trace:');
    print(stackTrace);
    exit(1);
  }
}

