import 'dart:io';
import 'package:path/path.dart' as path;
import '../../domain/entities/project_config.dart';

/// Data source for file system operations
abstract class FileSystemDataSource {
  Future<void> addDependencies(String projectName, StateManagementType stateManagement, bool includeGoRouter);
  Future<void> createDirectoryStructure(String projectName, StateManagementType stateManagement, bool includeGoRouter);
  Future<void> createStateManagementTemplates(String projectName, StateManagementType stateManagement);
  Future<void> createGoRouterTemplates(String projectName);
  Future<void> updateMainFile(String projectName, StateManagementType stateManagement, bool includeGoRouter);
}

/// Implementation of FileSystemDataSource
class FileSystemDataSourceImpl implements FileSystemDataSource {
  @override
  Future<void> addDependencies(String projectName, StateManagementType stateManagement, bool includeGoRouter) async {
    final pubspecPath = path.join(projectName, 'pubspec.yaml');
    final pubspecFile = File(pubspecPath);
    
    if (!pubspecFile.existsSync()) {
      throw FileSystemException('pubspec.yaml not found');
    }

    String pubspecContent = pubspecFile.readAsStringSync();
    
    // Add state management dependencies
    switch (stateManagement) {
      case StateManagementType.bloc:
      case StateManagementType.cubit:
        pubspecContent = pubspecContent.replaceFirst(
          'dependencies:',
          '''dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5'''
        );
        break;
      case StateManagementType.provider:
        pubspecContent = pubspecContent.replaceFirst(
          'dependencies:',
          '''dependencies:
  provider: ^6.1.1'''
        );
        break;
      case StateManagementType.none:
        break; // No state management dependencies
    }

    // Add Go Router dependency if requested
    if (includeGoRouter) {
      if (pubspecContent.contains('go_router:')) {
        // Already added
      } else {
        pubspecContent = pubspecContent.replaceFirst(
          'dependencies:',
          '''dependencies:
  go_router: ^13.2.0'''
        );
      }
    }

    pubspecFile.writeAsStringSync(pubspecContent);
  }

  @override
  Future<void> createDirectoryStructure(String projectName, StateManagementType stateManagement, bool includeGoRouter) async {
    final directories = [
      'lib/blocs',
      'lib/cubits', 
      'lib/providers',
      'lib/models',
      'lib/repositories',
      'lib/services',
      'lib/utils',
    ];

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
  Future<void> createStateManagementTemplates(String projectName, StateManagementType stateManagement) async {
    switch (stateManagement) {
      case StateManagementType.bloc:
        await _createBlocTemplates(projectName);
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

    // Create sample pages
    final homePageFile = File(path.join(projectName, 'lib/pages/home_page.dart'));
    homePageFile.writeAsStringSync(_generateHomePageContent());

    final aboutPageFile = File(path.join(projectName, 'lib/pages/about_page.dart'));
    aboutPageFile.writeAsStringSync(_generateAboutPageContent());

    final settingsPageFile = File(path.join(projectName, 'lib/pages/settings_page.dart'));
    settingsPageFile.writeAsStringSync(_generateSettingsPageContent());
  }

  @override
  Future<void> updateMainFile(String projectName, StateManagementType stateManagement, bool includeGoRouter) async {
    final mainPath = path.join(projectName, 'lib/main.dart');
    final mainFile = File(mainPath);
    
    if (!mainFile.existsSync()) {
      throw FileSystemException('main.dart not found');
    }

    final mainContent = _generateMainContent(stateManagement, includeGoRouter);
    mainFile.writeAsStringSync(mainContent);
  }

  Future<void> _createBlocTemplates(String projectName) async {
    final blocDir = path.join(projectName, 'lib/blocs');
    
    // Create event file
    final eventFile = File(path.join(blocDir, 'counter_event.dart'));
    eventFile.writeAsStringSync(_generateBlocEventContent());

    // Create state file
    final stateFile = File(path.join(blocDir, 'counter_state.dart'));
    stateFile.writeAsStringSync(_generateBlocStateContent());

    // Create bloc file
    final blocFile = File(path.join(blocDir, 'counter_bloc.dart'));
    blocFile.writeAsStringSync(_generateBlocContent());
  }

  Future<void> _createCubitTemplates(String projectName) async {
    final cubitDir = path.join(projectName, 'lib/cubits');
    
    // Create state file
    final stateFile = File(path.join(cubitDir, 'counter_state.dart'));
    stateFile.writeAsStringSync(_generateCubitStateContent());

    // Create cubit file
    final cubitFile = File(path.join(cubitDir, 'counter_cubit.dart'));
    cubitFile.writeAsStringSync(_generateCubitContent());
  }

  Future<void> _createProviderTemplates(String projectName) async {
    final providerDir = path.join(projectName, 'lib/providers');
    
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
import 'counter_event.dart';
import 'counter_state.dart';

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(CounterInitial()) {
    on<IncrementCounter>(_onIncrement);
    on<DecrementCounter>(_onDecrement);
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
      emit(CounterLoaded(currentState.count - 1));
    } else {
      emit(const CounterLoaded(-1));
    }
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
import 'counter_state.dart';

class CounterCubit extends Cubit<CounterState> {
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

  String _generateMainContent(StateManagementType stateManagement, bool includeGoRouter) {
    String baseContent;
    
    switch (stateManagement) {
      case StateManagementType.bloc:
        baseContent = _generateBlocMainContent();
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

    // Add Go Router integration if requested
    if (includeGoRouter) {
      return _integrateGoRouter(baseContent);
    }

    return baseContent;
  }

  String _integrateGoRouter(String baseContent) {
    // Add Go Router import
    if (!baseContent.contains('import \'package:go_router/go_router.dart\';')) {
      baseContent = baseContent.replaceFirst(
        'import \'package:flutter/material.dart\';',
        '''import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes/app_router.dart';'''
      );
    }

    // Replace MaterialApp with MaterialApp.router
    baseContent = baseContent.replaceFirst(
      'MaterialApp(',
      'MaterialApp.router('
    );

    // Add router configuration
    baseContent = baseContent.replaceFirst(
      'MaterialApp.router(',
      '''MaterialApp.router(
        routerConfig: AppRouter.router,'''
    );

    return baseContent;
  }

  String _generateAppRouterContent() {
    return '''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/about_page.dart';
import '../pages/settings_page.dart';

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

  String _generateBlocMainContent() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'blocs/counter_bloc.dart';
import 'blocs/counter_event.dart';
import 'blocs/counter_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => CounterBloc(),
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
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
      ),
    );
  }
}
''';
  }

  String _generateCubitMainContent() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/counter_cubit.dart';
import 'cubits/counter_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => CounterCubit(),
        child: const MyHomePage(title: 'Flutter Demo Home Page'),
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
import 'providers/counter_provider.dart';

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
        title: 'Flutter Demo',
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
      title: 'Flutter Demo',
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
} 