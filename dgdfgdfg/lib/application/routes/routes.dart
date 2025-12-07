import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';

class Routes {
  const Routes._();
  static const String home = '/home';
}

class AppRoutes {
  AppRoutes._();

  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get globalContext => _navigatorKey.currentContext;

  static final GoRouter router = GoRouter(
    errorBuilder: (BuildContext context, GoRouterState state) {
      debugPrint('Error en ruta: ${state.error}');
      return Scaffold(
        body: Center(
          child: Text('Error en la ruta: ${state.error}', style: const TextStyle(fontSize: 20)),
        ),
      );
    },
    navigatorKey: _navigatorKey,
    debugLogDiagnostics: true,
    initialLocation: Routes.home,
    routes: <RouteBase>[
      GoRoute(
        path: Routes.home,
        builder: (BuildContext context, GoRouterState state) => const HomePage(),
      ),
    ],
  );
}

