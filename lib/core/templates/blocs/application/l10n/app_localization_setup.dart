import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizationsSetup {
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('es'),
  ];

  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates => [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

