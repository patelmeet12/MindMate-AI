import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/theme.dart';
import 'presentation/providers/providers.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load SharedPreferences ahead of building UI
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MindMateApp(),
    ),
  );
}

class MindMateApp extends ConsumerWidget {
  const MindMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'MindMate AI',
      debugShowCheckedModeBanner: false,

      // Calm theme mapping
      theme: MindMateTheme.buildTheme(
        isDark: false,
        isHighContrast: themeState.isHighContrast,
      ),
      darkTheme: MindMateTheme.buildTheme(
        isDark: true,
        isHighContrast: themeState.isHighContrast,
      ),

      // Read current state of theme (light/dark)
      themeMode: themeState.isDark ? ThemeMode.dark : ThemeMode.light,

      routerConfig: router,
    );
  }
}
