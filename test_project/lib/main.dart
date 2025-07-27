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
    themeAnimationStyle: const AnimationStyle(
      curve: Curves.easeInOut,
      duration: Duration(milliseconds: 300),
      reverseCurve: Curves.easeInOut,
      reverseDuration: Duration(milliseconds: 300),
    ),
  );
}
