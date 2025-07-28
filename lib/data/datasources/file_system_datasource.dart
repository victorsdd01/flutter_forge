import 'dart:io';
import 'package:path/path.dart' as path;
import '../../domain/entities/project_config.dart';

/// Data source for file system operations
abstract class FileSystemDataSource {
  Future<void> addDependencies(String projectName, StateManagementType stateManagement, bool includeGoRouter, bool includeCleanArchitecture, bool includeFreezed);
  Future<void> createDirectoryStructure(String projectName, StateManagementType stateManagement, bool includeGoRouter);
  Future<void> createStateManagementTemplates(String projectName, StateManagementType stateManagement, bool includeFreezed);
  Future<void> createGoRouterTemplates(String projectName);
  Future<void> createCleanArchitectureStructure(String projectName, StateManagementType stateManagement, {bool includeGoRouter = false, bool includeFreezed = false});
  Future<void> updateMainFile(String projectName, StateManagementType stateManagement, bool includeGoRouter, bool includeCleanArchitecture, bool includeFreezed);
  Future<void> createLinterRules(String projectName);
  Future<void> createBarrelFiles(String projectName, StateManagementType stateManagement, bool includeCleanArchitecture, bool includeFreezed);
  Future<void> createBuildYaml(String projectName);
  Future<void> createInternationalization(String projectName);
}

/// Implementation of FileSystemDataSource
class FileSystemDataSourceImpl implements FileSystemDataSource {
  @override
  Future<void> addDependencies(String projectName, StateManagementType stateManagement, bool includeGoRouter, bool includeCleanArchitecture, bool includeFreezed) async {
    final pubspecPath = path.join(projectName, 'pubspec.yaml');
    final pubspecFile = File(pubspecPath);
    
    if (!pubspecFile.existsSync()) {
      throw FileSystemException('pubspec.yaml not found');
    }

    String pubspecContent = pubspecFile.readAsStringSync();
    
    // Build dependencies list
    final dependencies = <String>[];
    
    // Add state management dependencies
    switch (stateManagement) {
      case StateManagementType.bloc:
        dependencies.addAll([
          'flutter_bloc: ^9.1.1',
          'hydrated_bloc: ^10.1.1',
          'replay_bloc: ^0.3.0',
          'bloc_concurrency: ^0.3.0',
          'dartz: ^0.10.1',
          'path_provider: ^2.1.5',
          'equatable: ^2.0.7',
          'get_it: ^8.0.3',
        ]);
        
        if (includeFreezed) {
          dependencies.addAll([
            'json_annotation: ^4.9.0',
            'freezed_annotation: ^2.4.4',
            'freezed: ^2.5.7',
          ]);
        }
        break;
      case StateManagementType.cubit:
        dependencies.addAll([
          'flutter_bloc: ^9.1.1',
          'hydrated_bloc: ^10.1.1',
          'equatable: ^2.0.7',
          'get_it: ^8.0.3',
        ]);
        break;
      case StateManagementType.provider:
        dependencies.addAll([
          'provider: ^6.1.5',
          'get_it: ^8.0.3',
        ]);
        break;
      case StateManagementType.none:
        break; // No state management dependencies
    }

    // Add Go Router dependency if requested
    if (includeGoRouter && !dependencies.any((d) => d.startsWith('go_router:'))) {
      dependencies.add('go_router: ^16.0.0');
    }

    // Add Clean Architecture dependencies if requested
    if (includeCleanArchitecture) {
      if (!dependencies.any((d) => d.startsWith('equatable:'))) {
        dependencies.add('equatable: ^2.0.7');
      }
      if (!dependencies.any((d) => d.startsWith('get_it:'))) {
        dependencies.add('get_it: ^8.0.3');
      }
    }

    // Add internationalization dependencies
    dependencies.addAll([
      'flutter_localizations:',
      '  sdk: flutter',
      'intl: any',
    ]);

    // Build dev dependencies list
    final devDependencies = <String>[];
    
    if (includeFreezed) {
      devDependencies.addAll([
        'json_serializable: ^6.8.0',
        'build_runner: ^2.4.13',
      ]);
    }

    // Add internationalization dev dependencies
    devDependencies.addAll([
      'intl_utils: ^2.8.10',
    ]);

    // Replace dependencies section
    if (dependencies.isNotEmpty) {
      final dependenciesSection = 'dependencies:\n  ${dependencies.join('\n  ')}';
      pubspecContent = pubspecContent.replaceFirst(
        RegExp(r'dependencies:\s*\n'),
        '$dependenciesSection\n'
      );
    }

    // Replace dev_dependencies section
    if (devDependencies.isNotEmpty) {
      final devDependenciesSection = 'dev_dependencies:\n  ${devDependencies.join('\n  ')}';
      pubspecContent = pubspecContent.replaceFirst(
        RegExp(r'dev_dependencies:\s*\n'),
        '$devDependenciesSection\n'
      );
    }

    pubspecFile.writeAsStringSync(pubspecContent);

    // Add flutter configuration for internationalization
    await _addFlutterConfiguration(projectName);
  }

  Future<void> _addFlutterConfiguration(String projectName) async {
    final pubspecPath = path.join(projectName, 'pubspec.yaml');
    final pubspecFile = File(pubspecPath);
    
    String pubspecContent = pubspecFile.readAsStringSync();
    
    // Add flutter configuration if not present
    if (!pubspecContent.contains('generate: true')) {
      // Find the flutter section and update it
      if (pubspecContent.contains('flutter:')) {
        pubspecContent = pubspecContent.replaceFirst(
          'uses-material-design: true',
          '''uses-material-design: true
  generate: true'''
        );
      }
    }

    // Add or update flutter_intl configuration at root level
    if (!pubspecContent.contains('flutter_intl:')) {
      final flutterIntlConfig = '''
flutter_intl:
  enabled: true
  arb_dir: lib/application/l10n
  output_dir: lib/application/generated
''';
      
      // Add flutter_intl configuration at the end of the file, before the last line
      final lastLineIndex = pubspecContent.lastIndexOf('\n');
      if (lastLineIndex != -1) {
        final beforeLastLine = pubspecContent.substring(0, lastLineIndex);
        final lastLine = pubspecContent.substring(lastLineIndex);
        pubspecContent = '$beforeLastLine\n$flutterIntlConfig$lastLine';
      } else {
        // Fallback: add at the end
        pubspecContent = '$pubspecContent\n$flutterIntlConfig';
      }
    }
    
    pubspecFile.writeAsStringSync(pubspecContent);
  }

  @override
  Future<void> createDirectoryStructure(String projectName, StateManagementType stateManagement, bool includeGoRouter) async {
    final directories = <String>[];

    // Add Go Router directories if requested
    if (includeGoRouter) {
      directories.addAll([
        'lib/routes',
        'lib/pages',
      ]);
    }

    for (final dir in directories) {
      Directory(path.join(projectName, dir)).createSync(recursive: true);
    }
  }

  @override
  Future<void> createStateManagementTemplates(String projectName, StateManagementType stateManagement, bool includeFreezed) async {
    switch (stateManagement) {
      case StateManagementType.bloc:
        await _createBlocTemplates(projectName, includeFreezed);
        break;
      case StateManagementType.cubit:
        await _createCubitTemplates(projectName);
        break;
      case StateManagementType.provider:
        await _createProviderTemplates(projectName);
        break;
      case StateManagementType.none:
        break;
    }
  }

  @override
  Future<void> createGoRouterTemplates(String projectName) async {
    // Create app_router.dart
    final routerFile = File(path.join(projectName, 'lib/routes/app_router.dart'));
    routerFile.writeAsStringSync(_generateAppRouterContent());

    // Check if Clean Architecture structure exists to determine page location
    final cleanArchPagesDir = Directory(path.join(projectName, 'lib/presentation/pages'));
    
    String pagesPath;
    if (cleanArchPagesDir.existsSync()) {
      // Clean Architecture structure exists, use presentation/pages
      pagesPath = 'lib/presentation/pages';
    } else {
      // Regular structure, use pages
      pagesPath = 'lib/pages';
    }

    // Create sample pages
    final homePageFile = File(path.join(projectName, '$pagesPath/home_page.dart'));
    homePageFile.writeAsStringSync(_generateHomePageContent());

    final aboutPageFile = File(path.join(projectName, '$pagesPath/about_page.dart'));
    aboutPageFile.writeAsStringSync(_generateAboutPageContent());

    final settingsPageFile = File(path.join(projectName, '$pagesPath/settings_page.dart'));
    settingsPageFile.writeAsStringSync(_generateSettingsPageContent());
  }





  @override
  Future<void> updateMainFile(String projectName, StateManagementType stateManagement, bool includeGoRouter, bool includeCleanArchitecture, bool includeFreezed) async {
    final mainPath = path.join(projectName, 'lib/main.dart');
    final mainFile = File(mainPath);
    
    if (!mainFile.existsSync()) {
      throw FileSystemException('main.dart not found');
    }

    final mainContent = _generateMainContent(stateManagement, includeGoRouter, includeCleanArchitecture, includeFreezed);
    mainFile.writeAsStringSync(mainContent);
  }

  Future<void> _createBlocTemplates(String projectName, bool includeFreezed) async {
    final blocDir = path.join(projectName, 'lib/presentation/blocs');
    
    if (includeFreezed) {
      // Create Freezed BLoC files
      final blocFile = File(path.join(blocDir, 'sample_bloc.dart'));
      blocFile.writeAsStringSync(_generateFreezedBlocContent());

      final eventFile = File(path.join(blocDir, 'sample_event.dart'));
      eventFile.writeAsStringSync(_generateFreezedEventContent());

      final stateFile = File(path.join(blocDir, 'sample_state.dart'));
      stateFile.writeAsStringSync(_generateFreezedStateContent());
    } else {
      // Create regular BLoC files
      final eventFile = File(path.join(blocDir, 'counter_event.dart'));
      eventFile.writeAsStringSync(_generateBlocEventContent());

      final stateFile = File(path.join(blocDir, 'counter_state.dart'));
      stateFile.writeAsStringSync(_generateBlocStateContent());

      final blocFile = File(path.join(blocDir, 'counter_bloc.dart'));
      blocFile.writeAsStringSync(_generateBlocContent());
    }
  }

  Future<void> _createCubitTemplates(String projectName) async {
    final cubitDir = path.join(projectName, 'lib/presentation/cubits');
    
    // Create state file
    final stateFile = File(path.join(cubitDir, 'counter_state.dart'));
    stateFile.writeAsStringSync(_generateCubitStateContent());

    // Create cubit file
    final cubitFile = File(path.join(cubitDir, 'counter_cubit.dart'));
    cubitFile.writeAsStringSync(_generateCubitContent());
  }

  Future<void> _createProviderTemplates(String projectName) async {
    final providerDir = path.join(projectName, 'lib/presentation/providers');
    
    // Create provider file
    final providerFile = File(path.join(providerDir, 'counter_provider.dart'));
    providerFile.writeAsStringSync(_generateProviderContent());
  }

  String _generateBlocEventContent() {
    return '''
import 'package:equatable/equatable.dart';

abstract class CounterEvent extends Equatable {
  const CounterEvent();

  @override
  List<Object> get props => [];
}

class IncrementCounter extends CounterEvent {}

class DecrementCounter extends CounterEvent {}
''';
  }

  String _generateBlocStateContent() {
    return '''
import 'package:equatable/equatable.dart';

abstract class CounterState extends Equatable {
  const CounterState();
  
  @override
  List<Object> get props => [];
}

class CounterInitial extends CounterState {}

class CounterLoading extends CounterState {}

class CounterLoaded extends CounterState {
  final int count;
  
  const CounterLoaded(this.count);
  
  @override
  List<Object> get props => [count];
}

class CounterError extends CounterState {
  final String message;
  
  const CounterError(this.message);
  
  @override
  List<Object> get props => [message];
}
''';
  }

  String _generateBlocContent() {
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'counter_event.dart';
import 'counter_state.dart';

class CounterBloc extends HydratedBloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    on<IncrementCounter>(
      _onIncrement,
      transformer: restartable(),
    );
    on<DecrementCounter>(
      _onDecrement,
      transformer: restartable(),
    );
  }

  void _onIncrement(IncrementCounter event, Emitter<CounterState> emit) {
    if (state is CounterLoaded) {
      final currentState = state as CounterLoaded;
      emit(CounterLoaded(currentState.count + 1));
    } else {
      emit(const CounterLoaded(1));
    }
  }

  void _onDecrement(DecrementCounter event, Emitter<CounterState> emit) {
    if (state is CounterLoaded) {
      final currentState = state as CounterLoaded;
      if (currentState.count > 0) {
        emit(CounterLoaded(currentState.count - 1));
      }
    }
  }

  @override
  CounterState? fromJson(Map<String, dynamic> json) {
    return CounterLoaded(json['count'] as int);
  }

  @override
  Map<String, dynamic>? toJson(CounterState state) {
    if (state is CounterLoaded) {
      return {'count': state.count};
    }
    return null;
  }
}
''';
  }

  String _generateCubitStateContent() {
    return '''
import 'package:equatable/equatable.dart';

class CounterState extends Equatable {
  final int count;
  final String status;
  
  const CounterState({
    this.count = 0,
    this.status = 'initial',
  });
  
  CounterState copyWith({
    int? count,
    String? status,
  }) {
    return CounterState(
      count: count ?? this.count,
      status: status ?? this.status,
    );
  }
  
  @override
  List<Object> get props => [count, status];
}
''';
  }

  String _generateCubitContent() {
    return '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'counter_state.dart';

class CounterCubit extends HydratedCubit<CounterState> {
  CounterCubit() : super(const CounterState());

  void increment() {
    emit(state.copyWith(
      count: state.count + 1,
      status: 'incremented',
    ));
  }

  void decrement() {
    emit(state.copyWith(
      count: state.count - 1,
      status: 'decremented',
    ));
  }

  void reset() {
    emit(const CounterState());
  }

  @override
  CounterState? fromJson(Map<String, dynamic> json) {
    return CounterState(
      count: json['count'] as int? ?? 0,
      status: json['status'] as String? ?? 'initial',
    );
  }

  @override
  Map<String, dynamic>? toJson(CounterState state) {
    return {
      'count': state.count,
      'status': state.status,
    };
  }
}
''';
  }

  String _generateProviderContent() {
    return '''
import 'package:flutter/foundation.dart';

class CounterProvider with ChangeNotifier {
  int _count = 0;
  
  int get count => _count;
  
  void increment() {
    _count++;
    notifyListeners();
  }
  
  void decrement() {
    _count--;
    notifyListeners();
  }
  
  void reset() {
    _count = 0;
    notifyListeners();
  }
}
''';
  }

  String _generateMainContent(StateManagementType stateManagement, bool includeGoRouter, bool includeCleanArchitecture, bool includeFreezed) {
    // Generate the complete main.dart content based on all options
    if (stateManagement == StateManagementType.bloc && includeFreezed && includeGoRouter && includeCleanArchitecture) {
      return _generateFreezedBlocWithGoRouterAndCleanArchitecture();
    } else if (stateManagement == StateManagementType.bloc && includeFreezed && includeCleanArchitecture) {
      return _generateFreezedBlocWithCleanArchitecture();
    } else if (stateManagement == StateManagementType.bloc && includeFreezed && includeGoRouter) {
      return _generateFreezedBlocWithGoRouter();
    } else if (stateManagement == StateManagementType.bloc && includeFreezed) {
      return _generateBlocMainContent(includeFreezed);
    } else if (stateManagement == StateManagementType.bloc && includeGoRouter) {
      return _generateBlocWithGoRouter(includeFreezed);
    } else if (stateManagement == StateManagementType.cubit && includeGoRouter) {
      return _generateCubitWithGoRouter();
    } else {
      // Fallback to the original approach for other combinations
      String baseContent;
      
      switch (stateManagement) {
        case StateManagementType.bloc:
          baseContent = _generateBlocMainContent(includeFreezed);
          break;
        case StateManagementType.cubit:
          baseContent = _generateCubitMainContent();
          break;
        case StateManagementType.provider:
          baseContent = _generateProviderMainContent();
          break;
        case StateManagementType.none:
          baseContent = _generateBasicMainContent();
          break;
      }

      // Add Clean Architecture integration if requested
      if (includeCleanArchitecture) {
        baseContent = _integrateCleanArchitecture(baseContent, stateManagement);
      }

      // Add Go Router integration if requested (after Clean Architecture)
      if (includeGoRouter) {
        baseContent = _integrateGoRouter(baseContent);
      }

      return baseContent;
    }
  }

  String _integrateCleanArchitecture(String baseContent, StateManagementType stateManagement) {
    // Update imports to use Clean Architecture structure
    if (!baseContent.contains('import \'core/di/dependency_injection.dart\';')) {
      baseContent = baseContent.replaceFirst(
        'import \'package:flutter/material.dart\';',
        '''import 'package:flutter/material.dart';
import 'core/di/dependency_injection.dart';'''
      );
    }

    // Update main function to initialize Injector (handle both async and sync main)
    if (baseContent.contains('Future<void> main() async {')) {
      if (!baseContent.contains('Injector.init();')) {
        baseContent = baseContent.replaceFirst(
          'Future<void> main() async {',
          '''Future<void> main() async {
  // Initialize dependency injection
  Injector.init();'''
        );
      }
    } else if (baseContent.contains('void main() async {')) {
      baseContent = baseContent.replaceFirst(
        'void main() async {',
        '''Future<void> main() async {
  // Initialize dependency injection
  Injector.init();'''
      );
    } else {
      baseContent = baseContent.replaceFirst(
        'void main()',
        '''Future<void> main() async {
  // Initialize dependency injection
  Injector.init();'''
      );
    }

    // Update MaterialApp to use Clean Architecture structure
    if (!baseContent.contains('debugShowCheckedModeBanner: false')) {
      baseContent = baseContent.replaceFirst(
        'MaterialApp(',
        '''MaterialApp(
        debugShowCheckedModeBanner: false,'''
      );
    }

    // Update home page reference to use Clean Architecture path
    baseContent = baseContent.replaceFirst(
      'home: const MyHomePage(',
      'home: const HomePage('
    );

    // Remove the old MyHomePage class if it exists
    if (baseContent.contains('class MyHomePage extends StatefulWidget')) {
      final startIndex = baseContent.indexOf('class MyHomePage extends StatefulWidget');
      final endIndex = baseContent.lastIndexOf('}');
      if (startIndex != -1 && endIndex != -1) {
        baseContent = baseContent.substring(0, startIndex) + baseContent.substring(endIndex + 1);
      }
    }

    return baseContent;
  }

  String _integrateGoRouter(String baseContent) {
    // Add Go Router import
    if (!baseContent.contains('import \'routes/app_router.dart\';')) {
      baseContent = baseContent.replaceFirst(
        'import \'package:flutter/material.dart\';',
        '''import 'package:flutter/material.dart';
import 'routes/app_router.dart';'''
      );
    }

    // Replace MaterialApp with MaterialApp.router
    baseContent = baseContent.replaceFirst(
      'MaterialApp(',
      'MaterialApp.router('
    );

    // Add router configuration and remove home property
    if (!baseContent.contains('routerConfig: AppRouter.router')) {
      baseContent = baseContent.replaceFirst(
        'MaterialApp.router(',
        '''MaterialApp.router(
          routerConfig: AppRouter.router,'''
      );
    }

    // Remove the home property since we're using router
    if (baseContent.contains('home: ')) {
      final homeStart = baseContent.indexOf('home: ');
      final homeEnd = baseContent.indexOf(',', homeStart);
      if (homeEnd != -1) {
        baseContent = baseContent.substring(0, homeStart) + baseContent.substring(homeEnd + 1);
      }
    }

    return baseContent;
  }

  String _generateAppRouterContent() {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/about_page.dart';
import '../presentation/pages/settings_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/about',
        name: 'about',
        builder: (context, state) => const AboutPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}

// Navigation service for easy navigation
class NavigationService {
  static void goToHome(BuildContext context) {
    context.go('/');
  }

  static void goToAbout(BuildContext context) {
    context.go('/about');
  }

  static void goToSettings(BuildContext context) {
    context.go('/settings');
  }

  static void goBack(BuildContext context) {
    context.pop();
  }
}
''';
  }

  String _generateHomePageContent() {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Your Flutter App!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'This is your home page with Go Router navigation.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => context.go('/about'),
                  child: const Text('About'),
                ),
                ElevatedButton(
                  onPressed: () => context.go('/settings'),
                  child: const Text('Settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
''';
  }

  String _generateAboutPageContent() {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About This App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'This is a Flutter application created with VMGV CLI.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Features:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('• Go Router for navigation'),
            Text('• Clean architecture'),
            Text('• State management'),
            Text('• Best practices'),
          ],
        ),
      ),
    );
  }
}
''';
  }

  String _generateSettingsPageContent() {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Enable dark theme'),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Notifications'),
              subtitle: const Text('Enable push notifications'),
              value: _notifications,
              onChanged: (value) {
                setState(() {
                  _notifications = value;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Navigation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Go to Home'),
              onTap: () => context.go('/'),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Go to About'),
              onTap: () => context.go('/about'),
            ),
          ],
        ),
      ),
    );
  }
}
''';
  }

  String _generateFreezedBlocWithGoRouterAndCleanArchitecture() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/blocs/sample_bloc.dart';
import 'routes/app_router.dart';
import 'application/generated/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runMainApp();
}

Future<void> runMainApp() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  Injector.init();

  runApp(MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<SampleBloc>(
          create: (BuildContext _) => Injector.get<SampleBloc>(),
        ),
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    routerConfig: AppRouter.router,
    localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
    supportedLocales: AppLocalizationsSetup.supportedLocales,
    debugShowCheckedModeBanner: kDebugMode,
    themeAnimationCurve: Curves.easeInOut,
    themeAnimationDuration: const Duration(milliseconds: 300),
    themeAnimationStyle: AnimationStyle(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
      reverseCurve: Curves.easeInOut,
      reverseDuration: const Duration(milliseconds: 300),
    ),
  );
}
''';
  }

  String _generateFreezedBlocWithCleanArchitecture() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/blocs/sample_bloc.dart';
import 'presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runMainApp();
}

Future<void> runMainApp() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  Injector.init();

  runApp(MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<SampleBloc>(
          create: (BuildContext _) => Injector.get<SampleBloc>(),
        ),
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
''';
  }

  String _generateFreezedBlocWithGoRouter() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/blocs/sample_bloc.dart';
import 'routes/app_router.dart';
import 'application/generated/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runMainApp();
}

Future<void> runMainApp() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  Injector.init();

  runApp(MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<SampleBloc>(
          create: (BuildContext _) => Injector.get<SampleBloc>(),
        ),
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    routerConfig: AppRouter.router,
    localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
    supportedLocales: AppLocalizationsSetup.supportedLocales,
    debugShowCheckedModeBanner: kDebugMode,
    themeAnimationCurve: Curves.easeInOut,
    themeAnimationDuration: const Duration(milliseconds: 300),
    themeAnimationStyle: AnimationStyle(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
      reverseCurve: Curves.easeInOut,
      reverseDuration: const Duration(milliseconds: 300),
    ),
  );
}
''';
  }

  String _generateBlocWithGoRouter(bool includeFreezed) {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'presentation/blocs/counter_bloc.dart';
import 'routes/app_router.dart';
import 'application/generated/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runMainApp();
}

Future<void> runMainApp() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  runApp(MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<CounterBloc>(
          create: (BuildContext _) => CounterBloc(),
        ),
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    routerConfig: AppRouter.router,
    localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
    supportedLocales: AppLocalizationsSetup.supportedLocales,
    debugShowCheckedModeBanner: kDebugMode,
    themeAnimationCurve: Curves.easeInOut,
    themeAnimationDuration: const Duration(milliseconds: 300),
    themeAnimationStyle: AnimationStyle(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
      reverseCurve: Curves.easeInOut,
      reverseDuration: const Duration(milliseconds: 300),
    ),
  );
}
''';
  }

  String _generateCubitWithGoRouter() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'presentation/cubits/counter_cubit.dart';
import 'presentation/cubits/counter_state.dart';
import 'routes/app_router.dart';
import 'application/generated/l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runMainApp();
}

Future<void> runMainApp() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  runApp(MultiBlocProvider(
    providers: <SingleChildWidget>[
      BlocProvider<CounterCubit>(
        create: (BuildContext _) => CounterCubit(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    routerConfig: AppRouter.router,
    localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
    supportedLocales: AppLocalizationsSetup.supportedLocales,
    debugShowCheckedModeBanner: kDebugMode,
    themeAnimationCurve: Curves.easeInOut,
    themeAnimationDuration: const Duration(milliseconds: 300),
    themeAnimationStyle: AnimationStyle(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
      reverseCurve: Curves.easeInOut,
      reverseDuration: const Duration(milliseconds: 300),
    ),
  );
}
''';
  }

  String _generateBlocMainContent(bool includeFreezed) {
    if (includeFreezed) {
      return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/blocs/sample_bloc.dart';
import 'presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runMainApp();
}

Future<void> runMainApp() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  Injector.init();

  runApp(MultiBlocProvider(
      providers: [
        BlocProvider<SampleBloc>(
          create: (BuildContext _) => Injector.get<SampleBloc>(),
        ),
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
''';
    } else {
      return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'presentation/blocs/counter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runMainApp();
}

Future<void> runMainApp() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  runApp(MultiBlocProvider(
      providers: [
        BlocProvider<CounterBloc>(
          create: (BuildContext _) => CounterBloc(),
        ),
      ],
      child: const MyApp()
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            BlocBuilder<CounterBloc, CounterState>(
              builder: (context, state) {
                if (state is CounterLoaded) {
                  return Text(
                    '\${state.count}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                }
                return const Text('0');
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              context.read<CounterBloc>().add(DecrementCounter());
            },
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              context.read<CounterBloc>().add(IncrementCounter());
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
            ),
          ],
        ],
      ),
    );
  }
}
''';
    }
  }

  String _generateCubitMainContent() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'presentation/cubits/counter_cubit.dart';
import 'presentation/cubits/counter_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await runMainApp();
}

Future<void> runMainApp() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<CounterCubit>(
        create: (BuildContext _) => CounterCubit(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            BlocBuilder<CounterCubit, CounterState>(
              builder: (context, state) {
                return Text(
                  '\${state.count}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              context.read<CounterCubit>().decrement();
            },
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              context.read<CounterCubit>().increment();
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
''';
  }

  String _generateProviderMainContent() {
    return '''
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/counter_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CounterProvider(),
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Consumer<CounterProvider>(
              builder: (context, counter, child) {
                return Text(
                  '\${counter.count}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              context.read<CounterProvider>().decrement();
            },
            tooltip: 'Decrement',
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            onPressed: () {
              context.read<CounterProvider>().increment();
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
''';
  }

  String _generateBasicMainContent() {
    return '''
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '\$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';
  }

  @override
  Future<void> createCleanArchitectureStructure(String projectName, StateManagementType stateManagement, {bool includeGoRouter = false, bool includeFreezed = false}) async {
    // Create Clean Architecture directory structure
    final cleanArchDirectories = [
      'lib/core',
      'lib/core/constants',
      'lib/core/errors',
      'lib/core/utils',
      'lib/core/di',
      'lib/domain',
      'lib/domain/entities',
      'lib/domain/repositories',
      'lib/domain/usecases',
      'lib/data',
      'lib/data/datasources',
      'lib/data/repositories',
      'lib/data/models',
      'lib/presentation',
      'lib/presentation/pages',
      'lib/presentation/widgets',
    ];

    // Add state management specific directories based on selection
    switch (stateManagement) {
      case StateManagementType.bloc:
        cleanArchDirectories.add('lib/presentation/blocs');
        break;
      case StateManagementType.cubit:
        cleanArchDirectories.add('lib/presentation/cubits');
        break;
      case StateManagementType.provider:
        cleanArchDirectories.add('lib/presentation/providers');
        break;
      case StateManagementType.none:
        // No state management directories needed
        break;
    }

    // Add Go Router directories if requested
    if (includeGoRouter) {
      cleanArchDirectories.addAll([
        'lib/routes',
      ]);
    }

    for (final dir in cleanArchDirectories) {
      Directory(path.join(projectName, dir)).createSync(recursive: true);
    }

    // Create base files for Clean Architecture
    await _createCleanArchitectureBaseFiles(projectName, stateManagement, includeFreezed);
  }

  Future<void> _createCleanArchitectureBaseFiles(String projectName, StateManagementType stateManagement, bool includeFreezed) async {
    // Create base entity
    final entityFile = File(path.join(projectName, 'lib/domain/entities/base_entity.dart'));
    entityFile.writeAsStringSync(_generateBaseEntityContent());

    // Create sample entity
    final sampleEntityFile = File(path.join(projectName, 'lib/domain/entities/sample_entity.dart'));
    sampleEntityFile.writeAsStringSync(_generateSampleEntityContent(includeFreezed));

    // Create base repository
    final repositoryFile = File(path.join(projectName, 'lib/domain/repositories/base_repository.dart'));
    repositoryFile.writeAsStringSync(_generateBaseRepositoryContent());

    // Create sample repository interface
    final sampleRepositoryFile = File(path.join(projectName, 'lib/domain/repositories/sample_repository.dart'));
    sampleRepositoryFile.writeAsStringSync(_generateSampleRepositoryContent());

    // Create base use case
    final useCaseFile = File(path.join(projectName, 'lib/domain/usecases/base_usecase.dart'));
    useCaseFile.writeAsStringSync(_generateBaseUseCaseContent());

    // Create sample use case
    final sampleUseCaseFile = File(path.join(projectName, 'lib/domain/usecases/sample_usecase.dart'));
    sampleUseCaseFile.writeAsStringSync(_generateSampleUseCaseContent(projectName));

    // Create dependency injection
    final diFile = File(path.join(projectName, 'lib/core/di/dependency_injection.dart'));
    diFile.writeAsStringSync(_generateDependencyInjectionContent(projectName, stateManagement, includeFreezed));

    // Create base error classes
    final errorFile = File(path.join(projectName, 'lib/core/errors/failures.dart'));
    errorFile.writeAsStringSync(_generateFailuresContent());

    // Create base constants
    final constantsFile = File(path.join(projectName, 'lib/core/constants/app_constants.dart'));
    constantsFile.writeAsStringSync(_generateAppConstantsContent());

    // Create Clean Architecture HomePage
    final homePageFile = File(path.join(projectName, 'lib/presentation/pages/home_page.dart'));
    homePageFile.writeAsStringSync(_generateCleanArchitectureHomePageContent(projectName));

    // Create data layer files
    await _createDataLayerFiles(projectName, includeFreezed);
  }


  String _generateBaseEntityContent() {
    return '''
import 'package:equatable/equatable.dart';

/// Base entity class for all domain entities
abstract class BaseEntity extends Equatable {
  const BaseEntity();
  
  @override
  List<Object?> get props => [];
}
''';
  }

  String _generateBaseRepositoryContent() {
    return '''
/// Base repository interface for all repositories
abstract class BaseRepository {
  const BaseRepository();
}
''';
  }

  String _generateSampleEntityContent(bool includeFreezed) {
    if (includeFreezed) {
      return '''import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/sample_model.dart';

part 'sample_entity.freezed.dart';
part 'sample_entity.g.dart';

/// Sample entity for demonstration
@freezed
abstract class SampleEntity with _\$SampleEntity {
  const factory SampleEntity({
    required String id,
    required String name,
    required String description,
  }) = _SampleEntity;

  factory SampleEntity.fromJson(Map<String, dynamic> json) => _\$SampleEntityFromJson(json);

  factory SampleEntity.fromModel(SampleModel model) => SampleEntity(
    id: model.id,
    name: model.name,
    description: model.description,
  );
}
''';
    } else {
      return '''import 'package:equatable/equatable.dart';
import 'base_entity.dart';
import '../../data/models/sample_model.dart';

/// Sample entity for demonstration
class SampleEntity extends BaseEntity {
  final String id;
  final String name;
  final String description;

  const SampleEntity({
    required this.id,
    required this.name,
    required this.description,
  });

  factory SampleEntity.fromModel(SampleModel model) => SampleEntity(
    id: model.id,
    name: model.name,
    description: model.description,
  );

  @override
  List<Object?> get props => [id, name, description];
}
''';
    }
  }

  String _generateSampleRepositoryContent() {
    return '''
import 'package:dartz/dartz.dart';
import '../entities/sample_entity.dart';
import '../../core/errors/failures.dart';
import 'base_repository.dart';

/// Sample repository interface
abstract class SampleRepository extends BaseRepository {
  Future<Either<Failure, List<SampleEntity>>> getSamples();
  Future<Either<Failure, SampleEntity>> getSampleById(String id);
  Future<Either<Failure, SampleEntity>> createSample(SampleEntity sample);
  Future<Either<Failure, SampleEntity>> updateSample(SampleEntity sample);
  Future<Either<Failure, bool>> deleteSample(String id);
}
''';
  }

  String _generateBaseUseCaseContent() {
    return '''
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';

/// Base use case class for all use cases
abstract class BaseUseCase<Type, Params> {
  const BaseUseCase();
  
  Future<Either<Failure, Type>> call(Params params);
}

/// No parameters use case
abstract class NoParamsUseCase<Type> {
  const NoParamsUseCase();
  
  Future<Either<Failure, Type>> call();
}
''';
  }

  String _generateDependencyInjectionContent(String projectName, StateManagementType stateManagement, bool includeFreezed) {
    // Generate conditional imports based on state management type
    String blocImports = '';
    String cubitImports = '';
    String providerImports = '';
    
    if (stateManagement == StateManagementType.bloc) {
      if (includeFreezed) {
        blocImports = '''
import '../../presentation/blocs/sample_bloc.dart';''';
      } else {
        blocImports = '''
import '../../presentation/blocs/counter_bloc.dart';''';
      }
    } else if (stateManagement == StateManagementType.cubit) {
      cubitImports = '''
import '../../presentation/cubits/counter_cubit.dart';''';
    } else if (stateManagement == StateManagementType.provider) {
      providerImports = '''
import '../../presentation/providers/counter_provider.dart';''';
    }
    
    // Generate conditional registration based on state management type
    String blocRegistration = '';
    String cubitRegistration = '';
    String providerRegistration = '';
    
    if (stateManagement == StateManagementType.bloc) {
      if (includeFreezed) {
        blocRegistration = '''
    // Register SampleBloc
    registerLazySingleton<SampleBloc>(() => SampleBloc(sampleUseCase: get<SampleUseCase>()));''';
      } else {
        blocRegistration = '''
    // Register CounterBloc
    registerLazySingleton<CounterBloc>(() => CounterBloc());''';
      }
    } else if (stateManagement == StateManagementType.cubit) {
      cubitRegistration = '''
    // Register CounterCubit
    registerLazySingleton<CounterCubit>(() => CounterCubit());''';
    } else if (stateManagement == StateManagementType.provider) {
      providerRegistration = '''
    // Register CounterProvider
    registerLazySingleton<CounterProvider>(() => CounterProvider());''';
    }
    
    return '''
import 'package:get_it/get_it.dart';
import '../../domain/usecases/sample_usecase.dart';$blocImports$cubitImports$providerImports

/// Custom Dependency Injection container using GetIt
class Injector {
  Injector._();

  static final GetIt _locator = GetIt.instance;

  static void init() {
    _registerDataSources();
    _registerRepositories();
    _registerUseCases();
    _registerBlocs();
  }

  static T get<T extends Object>() => _locator<T>();

  static void registerSingleton<T extends Object>(T instance) {
    _locator.registerSingleton<T>(instance);
  }

  static void registerLazySingleton<T extends Object>(T Function() factory) {
    _locator.registerLazySingleton<T>(factory);
  }

  static void registerFactory<T extends Object>(T Function() factory) {
    _locator.registerFactory<T>(factory);
  }

  //** ---- Data Sources ---- */
  static void _registerDataSources() {
    // Example: registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
    // Example: registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl());
  }

  //** ---- Repositories ---- */
  static void _registerRepositories() {
    // Example: registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
    //   authRemoteDataSource: get<AuthRemoteDataSource>(),
    //   authLocalDataSource: get<AuthLocalDataSource>(),
    // ));
  }

  //** ---- Use Cases ---- */
  static void _registerUseCases() {
    // Example: registerLazySingleton<AuthUseCases>(() => AuthUseCases(
    //   repository: get<AuthRepository>(),
    // ));
    
    // Sample use cases
    registerLazySingleton<SampleUseCase>(() => const SampleUseCase());
    registerLazySingleton<SampleWithParamsUseCase>(() => const SampleWithParamsUseCase());
  }

  //** ---- BLoCs ---- */
  static void _registerBlocs() {
    // Example: registerLazySingleton(() => AuthBloc(
    //   authUseCases: get<AuthUseCases>(),
    // ));
    $blocRegistration$cubitRegistration$providerRegistration
  }
}
''';
  }

  String _generateFailuresContent() {
    return '''
import 'package:equatable/equatable.dart';

/// Base failure class for all errors
abstract class Failure extends Equatable {
  const Failure([this.message = '']);
  
  final String message;
  
  @override
  List<Object?> get props => [message];
}

/// Server failure
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred']);
}

/// Cache failure
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred']);
}

/// Network failure
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error occurred']);
}
''';
  }

  String _generateAppConstantsContent() {
    return '''
/// Application constants
class AppConstants {
  const AppConstants._();
  
  // API URLs
  static const String baseUrl = 'https://api.example.com';
  
  // App Info
  static const String appName = 'Flutter App';
  static const String appVersion = '1.0.0';
  
  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
''';
  }

  String _generateSampleUseCaseContent(String projectName) {
    return '''
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import 'base_usecase.dart';

/// Sample use case demonstrating Either<Failure, Type> pattern
class SampleUseCase implements NoParamsUseCase<String> {
  const SampleUseCase();

  @override
  Future<Either<Failure, String>> call() async {
    try {
      // Simulate async operation
      await Future.delayed(const Duration(seconds: 1));
      
      // Return success
      return const Right('Sample use case executed successfully!');
    } catch (e) {
      // Return failure
      return Left(ServerFailure('Sample use case failed: \$e'));
    }
  }
}

/// Sample use case with parameters
class SampleWithParamsUseCase implements BaseUseCase<String, SampleParams> {
  const SampleWithParamsUseCase();

  @override
  Future<Either<Failure, String>> call(SampleParams params) async {
    try {
      // Simulate async operation with parameters
      await Future.delayed(const Duration(seconds: 1));
      
      // Return success with parameter
      return Right('Hello \${params.name}! Use case executed successfully!');
    } catch (e) {
      // Return failure
      return Left(ServerFailure('Sample use case failed: \$e'));
    }
  }
}

/// Sample parameters class
class SampleParams {
  final String name;
  
  const SampleParams({required this.name});
}
''';
  }

  String _generateCleanArchitectureHomePageContent(String projectName) {
    return '''
import 'package:flutter/material.dart';
import '../../core/di/dependency_injection.dart';

/// Clean Architecture HomePage
/// This page follows Clean Architecture principles and is located in the presentation layer
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Clean Architecture Home'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to Clean Architecture!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'You have pushed the button this many times:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              '\$_counter',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Column(
                children: [
                  Text(
                    '🏗️ Clean Architecture Structure:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('• lib/core/ - Constants, Errors, Utils, DI'),
                  Text('• lib/domain/ - Entities, Repositories, Use Cases'),
                  Text('• lib/data/ - Data Sources, Repositories, Models'),
                  Text('• lib/presentation/ - Pages, Widgets, BLoCs'),
                  SizedBox(height: 8),
                  Text(
                    '💉 Dependency Injection: GetIt + Custom Injector',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
''';
  }

  Future<void> _createDataLayerFiles(String projectName, bool includeFreezed) async {
    // Create sample model
    final sampleModelFile = File(path.join(projectName, 'lib/data/models/sample_model.dart'));
    sampleModelFile.writeAsStringSync(_generateSampleModelContent(includeFreezed));

    // Create sample repository implementation
    final sampleRepositoryImplFile = File(path.join(projectName, 'lib/data/repositories/sample_repository_impl.dart'));
    sampleRepositoryImplFile.writeAsStringSync(_generateSampleRepositoryImplContent());

    // Create sample data source
    final sampleDataSourceFile = File(path.join(projectName, 'lib/data/datasources/sample_data_source.dart'));
    sampleDataSourceFile.writeAsStringSync(_generateSampleDataSourceContent());
  }

  String _generateSampleDataSourceContent() {
    return '''
import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../models/sample_model.dart';

/// Sample data source interface
abstract class SampleDataSource {
  Future<Either<Failure, List<SampleModel>>> getSamples();
  Future<Either<Failure, SampleModel>> getSampleById(String id);
  Future<Either<Failure, SampleModel>> createSample(SampleModel sample);
  Future<Either<Failure, SampleModel>> updateSample(SampleModel sample);
  Future<Either<Failure, bool>> deleteSample(String id);
}

/// Remote data source implementation
class SampleRemoteDataSource implements SampleDataSource {
  @override
  Future<Either<Failure, List<SampleModel>>> getSamples() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final samples = [
        const SampleModel(id: '1', name: 'Sample 1', description: 'Description 1'),
        const SampleModel(id: '2', name: 'Sample 2', description: 'Description 2'),
      ];
      
      return Right(samples);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch samples: \$e'));
    }
  }

  @override
  Future<Either<Failure, SampleModel>> getSampleById(String id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final sample = SampleModel(id: id, name: 'Sample \$id', description: 'Description \$id');
      return Right(sample);
    } catch (e) {
      return Left(ServerFailure('Failed to fetch sample: \$e'));
    }
  }

  @override
  Future<Either<Failure, SampleModel>> createSample(SampleModel sample) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return Right(sample);
    } catch (e) {
      return Left(ServerFailure('Failed to create sample: \$e'));
    }
  }

  @override
  Future<Either<Failure, SampleModel>> updateSample(SampleModel sample) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return Right(sample);
    } catch (e) {
      return Left(ServerFailure('Failed to update sample: \$e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSample(String id) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure('Failed to delete sample: \$e'));
    }
  }
}

/// Local data source implementation
class SampleLocalDataSource implements SampleDataSource {
  @override
  Future<Either<Failure, List<SampleModel>>> getSamples() async {
    try {
      // Simulate local storage
      await Future.delayed(const Duration(milliseconds: 100));
      
      final samples = [
        const SampleModel(id: '1', name: 'Local Sample 1', description: 'Local Description 1'),
        const SampleModel(id: '2', name: 'Local Sample 2', description: 'Local Description 2'),
      ];
      
      return Right(samples);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch samples from cache: \$e'));
    }
  }

  @override
  Future<Either<Failure, SampleModel>> getSampleById(String id) async {
    try {
      // Simulate local storage
      await Future.delayed(const Duration(milliseconds: 100));
      
      final sample = SampleModel(id: id, name: 'Local Sample \$id', description: 'Local Description \$id');
      return Right(sample);
    } catch (e) {
      return Left(CacheFailure('Failed to fetch sample from cache: \$e'));
    }
  }

  @override
  Future<Either<Failure, SampleModel>> createSample(SampleModel sample) async {
    try {
      // Simulate local storage
      await Future.delayed(const Duration(milliseconds: 100));
      return Right(sample);
    } catch (e) {
      return Left(CacheFailure('Failed to create sample in cache: \$e'));
    }
  }

  @override
  Future<Either<Failure, SampleModel>> updateSample(SampleModel sample) async {
    try {
      // Simulate local storage
      await Future.delayed(const Duration(milliseconds: 100));
      return Right(sample);
    } catch (e) {
      return Left(CacheFailure('Failed to update sample in cache: \$e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSample(String id) async {
    try {
      // Simulate local storage
      await Future.delayed(const Duration(milliseconds: 100));
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure('Failed to delete sample from cache: \$e'));
    }
  }
}
''';
  }

  String _generateSampleRepositoryImplContent() {
    return '''
import 'package:dartz/dartz.dart';
import '../../domain/entities/sample_entity.dart';
import '../../domain/repositories/sample_repository.dart';
import '../../core/errors/failures.dart';
import '../datasources/sample_data_source.dart';
import '../models/sample_model.dart';

/// Implementation of SampleRepository
class SampleRepositoryImpl implements SampleRepository {
  final SampleDataSource _remoteDataSource;
  final SampleDataSource _localDataSource;

  SampleRepositoryImpl({
    required SampleDataSource remoteDataSource,
    required SampleDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<SampleEntity>>> getSamples() async {
    try {
      // Try remote first, fallback to local
      final remoteResult = await _remoteDataSource.getSamples();
      
      return remoteResult.fold(
        (failure) async {
          // If remote fails, try local
          final localResult = await _localDataSource.getSamples();
          return localResult.fold(
            (localFailure) => Left(ServerFailure('Both remote and local failed')),
            (localSamples) => Right(localSamples.map((model) => SampleEntity.fromModel(model)).toList()),
          );
        },
        (models) async {
          // If remote succeeds, cache the data
          for (final model in models) {
            await _localDataSource.createSample(model);
          }
          return Right(models.map((model) => SampleEntity.fromModel(model)).toList());
        },
      );
    } catch (e) {
      return Left(ServerFailure('Repository error: \$e'));
    }
  }

  @override
  Future<Either<Failure, SampleEntity>> getSampleById(String id) async {
    try {
      // Try remote first, fallback to local
      final remoteResult = await _remoteDataSource.getSampleById(id);
      
      return remoteResult.fold(
        (failure) async {
          // If remote fails, try local
          final localResult = await _localDataSource.getSampleById(id);
          return localResult.fold(
            (localFailure) => Left(ServerFailure('Sample not found')),
            (localModel) => Right(SampleEntity.fromModel(localModel)),
          );
        },
        (model) async {
          // If remote succeeds, cache the data
          await _localDataSource.createSample(model);
          return Right(SampleEntity.fromModel(model));
        },
      );
    } catch (e) {
      return Left(ServerFailure('Repository error: \$e'));
    }
  }

  @override
  Future<Either<Failure, SampleEntity>> createSample(SampleEntity sample) async {
    try {
      // Convert entity to model for datasource
      final model = SampleModel.fromEntity(sample);
      
      // Create in remote first
      final remoteResult = await _remoteDataSource.createSample(model);
      
      return remoteResult.fold(
        (failure) => Left(failure),
        (createdModel) async {
          // If remote succeeds, cache locally
          await _localDataSource.createSample(createdModel);
          return Right(SampleEntity.fromModel(createdModel));
        },
      );
    } catch (e) {
      return Left(ServerFailure('Repository error: \$e'));
    }
  }

  @override
  Future<Either<Failure, SampleEntity>> updateSample(SampleEntity sample) async {
    try {
      // Convert entity to model for datasource
      final model = SampleModel.fromEntity(sample);
      
      // Update in remote first
      final remoteResult = await _remoteDataSource.updateSample(model);
      
      return remoteResult.fold(
        (failure) => Left(failure),
        (updatedModel) async {
          // If remote succeeds, update locally
          await _localDataSource.updateSample(updatedModel);
          return Right(SampleEntity.fromModel(updatedModel));
        },
      );
    } catch (e) {
      return Left(ServerFailure('Repository error: \$e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSample(String id) async {
    try {
      // Delete from remote first
      final remoteResult = await _remoteDataSource.deleteSample(id);
      
      return remoteResult.fold(
        (failure) => Left(failure),
        (success) async {
          // If remote succeeds, delete locally
          await _localDataSource.deleteSample(id);
          return Right(success);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Repository error: \$e'));
    }
  }
}
''';
  }

  String _generateSampleModelContent(bool includeFreezed) {
    if (includeFreezed) {
      return '''import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/sample_entity.dart';

part 'sample_model.freezed.dart';
part 'sample_model.g.dart';

/// Sample model for demonstration
@freezed
class SampleModel with _\$SampleModel {
  const factory SampleModel({
    required String id,
    required String name,
    required String description,
  }) = _SampleModel;

  factory SampleModel.fromJson(Map<String, dynamic> json) => _\$SampleModelFromJson(json);

  factory SampleModel.fromEntity(SampleEntity entity) => SampleModel(
    id: entity.id,
    name: entity.name,
    description: entity.description,
  );
}
''';
    } else {
      return '''import 'package:equatable/equatable.dart';

/// Sample model for demonstration
class SampleModel extends Equatable {
  final String id;
  final String name;
  final String description;

  const SampleModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory SampleModel.fromJson(Map<String, dynamic> json) {
    return SampleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [id, name, description];
}
''';
    }
  }

  @override
  Future<void> createLinterRules(String projectName) async {
    final analysisOptionsPath = path.join(projectName, 'analysis_options.yaml');
    final analysisOptionsFile = File(analysisOptionsPath);
    
    final content = '''
include: package:flutter_lints/flutter.yaml

analyzer:
  errors:
    unnecessary_null_comparison: ignore
    invalid_annotation_target: ignore
    constant_identifier_names: ignore
  exclude:
    - bricks/**
    - '**/*.arb'
    - '**/*.g.dart'
    - '**/*.freezed.dart'
    - 'lib/application/generated/**'
    - 'lib/application/l10n/**.dart'
    - 'test/**'

linter:
  rules:
    always_specify_types: true
    prefer_expression_function_bodies: true
    always_declare_return_types: true
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: true
''';
    
    analysisOptionsFile.writeAsStringSync(content);
  }

  @override
  Future<void> createBarrelFiles(String projectName, StateManagementType stateManagement, bool includeCleanArchitecture, bool includeFreezed) async {
    if (!includeCleanArchitecture) return;

    // Create barrel files for each layer
    await _createCoreBarrelFile(projectName);
    await _createDomainBarrelFile(projectName);
    await _createDataBarrelFile(projectName);
    await _createPresentationBarrelFile(projectName, stateManagement, includeFreezed);
  }

  Future<void> _createCoreBarrelFile(String projectName) async {
    final barrelFile = File(path.join(projectName, 'lib/core/core.dart'));
    final content = '''
// Core layer exports
export 'constants/app_constants.dart';
export 'di/dependency_injection.dart';
export 'errors/failures.dart';
''';
    barrelFile.writeAsStringSync(content);
  }

  Future<void> _createDomainBarrelFile(String projectName) async {
    final barrelFile = File(path.join(projectName, 'lib/domain/domain.dart'));
    final content = '''
// Domain layer exports
export 'entities/base_entity.dart';
export 'entities/sample_entity.dart';
export 'repositories/base_repository.dart';
export 'repositories/sample_repository.dart';
export 'usecases/base_usecase.dart';
export 'usecases/sample_usecase.dart';
''';
    barrelFile.writeAsStringSync(content);
  }

  Future<void> _createDataBarrelFile(String projectName) async {
    final barrelFile = File(path.join(projectName, 'lib/data/data.dart'));
    final content = '''
// Data layer exports
export 'datasources/sample_data_source.dart';
export 'repositories/sample_repository_impl.dart';
export 'models/sample_model.dart';
''';
    barrelFile.writeAsStringSync(content);
  }

  Future<void> _createPresentationBarrelFile(String projectName, StateManagementType stateManagement, bool includeFreezed) async {
    final barrelFile = File(path.join(projectName, 'lib/presentation/presentation.dart'));
    
    String content = '''
// Presentation layer exports
export 'pages/home_page.dart';
''';

    // Add state management specific exports
    switch (stateManagement) {
      case StateManagementType.bloc:
        if (includeFreezed) {
          content += '''
export 'blocs/sample_bloc.dart';
''';
        } else {
          content += '''
export 'blocs/counter_bloc.dart';
export 'blocs/counter_event.dart';
export 'blocs/counter_state.dart';
''';
        }
        break;
      case StateManagementType.cubit:
        content += '''
export 'cubits/counter_cubit.dart';
export 'cubits/counter_state.dart';
''';
        break;
      case StateManagementType.provider:
        content += '''
export 'providers/counter_provider.dart';
''';
        break;
      case StateManagementType.none:
        break;
    }

    barrelFile.writeAsStringSync(content);
  }

  @override
  Future<void> createInternationalization(String projectName) async {
    // Create application directory structure
    final applicationDir = Directory(path.join(projectName, 'lib/application'));
    if (!applicationDir.existsSync()) {
      applicationDir.createSync(recursive: true);
    }

    // Create l10n directory
    final l10nDir = Directory(path.join(projectName, 'lib/application/l10n'));
    if (!l10nDir.existsSync()) {
      l10nDir.createSync(recursive: true);
    }

    // Create generated directory
    final generatedDir = Directory(path.join(projectName, 'lib/application/generated'));
    if (!generatedDir.existsSync()) {
      generatedDir.createSync(recursive: true);
    }

    // Create l10n subdirectory in generated (intl_utils expects this)
    final generatedL10nDir = Directory(path.join(projectName, 'lib/application/generated/l10n'));
    if (!generatedL10nDir.existsSync()) {
      generatedL10nDir.createSync(recursive: true);
    }

    // Create app_localizations.dart file with correct import
    final appLocalizationsFile = File(path.join(projectName, 'lib/application/generated/l10n/app_localizations.dart'));
    appLocalizationsFile.writeAsStringSync(_generateAppLocalizationsContent());

    // Create ARB files
    final intlEnFile = File(path.join(projectName, 'lib/application/l10n/intl_en.arb'));
    intlEnFile.writeAsStringSync(_generateIntlEnArbContent());

    final intlEsFile = File(path.join(projectName, 'lib/application/l10n/intl_es.arb'));
    intlEsFile.writeAsStringSync(_generateIntlEsArbContent());
  }

  String _generateAppLocalizationsContent() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../l10n.dart';

class AppLocalizationsSetup {
  static final List<Locale> supportedLocales = S.delegate.supportedLocales;

  static final Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
''';
  }

  String _generateIntlEnArbContent() {
    return '''{
  "@@locale": "en",
  "appTitle": "Flutter App",
  "@appTitle": {
    "description": "The title of the application"
  },
  "welcome": "Welcome",
  "@welcome": {
    "description": "Welcome message"
  },
  "hello": "Hello",
  "@hello": {
    "description": "Hello message"
  }
}''';
  }

  String _generateIntlEsArbContent() {
    return '''{
  "@@locale": "es",
  "appTitle": "Aplicación Flutter",
  "@appTitle": {
    "description": "El título de la aplicación"
  },
  "welcome": "Bienvenido",
  "@welcome": {
    "description": "Mensaje de bienvenida"
  },
  "hello": "Hola",
  "@hello": {
    "description": "Mensaje de hola"
  }
}''';
  }

  @override
  Future<void> createBuildYaml(String projectName) async {
    final buildYamlPath = path.join(projectName, 'build.yaml');
    final buildYamlFile = File(buildYamlPath);
    
    final content = '''targets:
  \$default:
    builders:
      json_serializable:
        options:
          explicit_to_json: true
''';
    
    buildYamlFile.writeAsStringSync(content);
  }

  String _generateFreezedBlocContent() {
    return '''import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/usecases/sample_usecase.dart';

part 'sample_bloc.g.dart';
part 'sample_bloc.freezed.dart';
part 'sample_event.dart';
part 'sample_state.dart';

class SampleBloc extends HydratedBloc<SampleEvent, SampleState> {
  final SampleUseCase _sampleUseCase;

  SampleBloc({required SampleUseCase sampleUseCase}) 
    : _sampleUseCase = sampleUseCase, super(const SampleState()) {
    on<SampleEvent>((SampleEvent event, Emitter<SampleState> emit) async {
      switch (event) {
         case _FetchData():
          {
            final Either<Failure, String> result = await _sampleUseCase();
            result.fold(
              (Failure failure) => emit(state.copyWith(failure: failure)),
              (String data) {
                emit(state.copyWith(
                  status: SampleStatus.success,
                  data: data,
                ));
              },
            );
            break;
          }
      }
    });
  }

  @override
  SampleState? fromJson(Map<String, dynamic> json) => SampleState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(SampleState state) => state.toJson();
}
''';
  }

  String _generateFreezedEventContent() {
    return '''part of 'sample_bloc.dart';

@freezed
sealed class SampleEvent with _\$SampleEvent {
  const factory SampleEvent.fetchData() = _FetchData;
}
''';
  }

  String _generateFreezedStateContent() {
    return '''part of 'sample_bloc.dart';

enum SampleStatus { 
  initial,
  loading,
  success,
  error,
}

@freezed
sealed class SampleState with _\$SampleState {
  const factory SampleState({
    @Default(SampleStatus.initial) SampleStatus status,
    @JsonKey(
      includeFromJson: false,
      includeToJson:   false,
    ) Failure? failure,
    @Default('') String data,
  }) = _SampleState;

  factory SampleState.fromJson(Map<String, dynamic> json) => _\$SampleStateFromJson(json);
}
''';
  }
}