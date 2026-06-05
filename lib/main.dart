import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'database/isar_service.dart';
import 'providers/recent_amounts_provider.dart';
import 'widgets/app_bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final IsarService isarService = await IsarService.init();
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: <Override>[
        isarServiceProvider.overrideWithValue(isarService),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const PocketLensApp(),
    ),
  );
}


class PocketLensApp extends StatelessWidget {
  const PocketLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Lens',
      theme: appTheme,
      home: const AppBottomNav(),
      debugShowCheckedModeBanner: false,
    );
  }
}

