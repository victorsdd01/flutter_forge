import 'package:talker_flutter/talker_flutter.dart';

class TalkerService {
  TalkerService._();
  
  static Talker? _instance;
  
  static Talker init() {
    if (_instance != null) {
      return _instance!;
    }

    _instance = TalkerFlutter.init(
      settings: TalkerSettings(
        enabled: true,
        useHistory: true,
        useConsoleLogs: false,
        maxHistoryItems: 1000,
      ),
    );

    return _instance!;
  }

  static Talker get instance {
    if (_instance == null) {
      return init();
    }
    return _instance!;
  }

  static void dispose() {
    _instance = null;
  }
}

