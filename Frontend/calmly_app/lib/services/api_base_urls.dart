import 'package:flutter/foundation.dart';

class ApiBaseUrls {
  const ApiBaseUrls._();

  static const String _defaultPort = '3000';

  static List<String> get values {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) {
      return [override];
    }

    if (kIsWeb) {
      return ['http://localhost:$_defaultPort'];
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android Emulator: 10.0.2.2 -> Host machine.
      // Physical Android with adb reverse: 127.0.0.1 works.
      return [
        'http://10.0.2.2:$_defaultPort',
        'http://127.0.0.1:$_defaultPort',
        'http://localhost:$_defaultPort',
      ];
    }

    return [
      'http://127.0.0.1:$_defaultPort',
      'http://localhost:$_defaultPort',
    ];
  }
}
