import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:nested/nested.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:{{project_name}}/core/core.dart';
import 'package:{{project_name}}/application/application.dart';
import 'package:{{project_name}}/features/home/presentation/blocs/home_bloc/home_bloc.dart';
import 'package:{{project_name}}/core/services/talker_service.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    if (kReleaseMode) {
      debugPrintRebuildDirtyWidgets = false;
      debugPrint = (String? message, {int? wrapWidth}) {};
    }
  } finally {
    await runMainApp();
  }
}

Future<void> runMainApp() async {
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  TalkerService.init();

  Injector.init();

  final sharedPrefs = Injector.get<SharedPreferencesUtils>();
  await sharedPrefs.init();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    return true;
  };

  runApp(
    MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<HomeBloc>(
          create: (BuildContext _) => Injector.get<HomeBloc>(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: AppTheme.light,
    themeMode: ThemeMode.light,
    routerConfig: AppRoutes.router,
    locale: AppLocalizationsSetup.supportedLocales.last,
    localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
    supportedLocales: AppLocalizationsSetup.supportedLocales,
    debugShowCheckedModeBanner: kDebugMode,
  );
} 