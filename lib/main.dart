import 'app_scroll_behavior.dart';
import 'providers/theme_provider.dart';
import 'utils/app_colors.dart';
import 'utils/deep_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  captureLaunchRoute();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Offline or test environment fallback
  }

  runApp(
    const ProviderScope(
      child: AreWeCookinApp(),
    ),
  );
}

class AreWeCookinApp extends ConsumerWidget {
  const AreWeCookinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    applyThemeToPalette(themeMode);

    ThemeData themeFor(Brightness brightness) => ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF5722), // Warm culinary orange
            brightness: brightness,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.slate(800),
            surfaceTintColor: Colors.transparent,
          ),
          dialogTheme: DialogThemeData(backgroundColor: AppColors.surface),
          bottomSheetTheme: BottomSheetThemeData(backgroundColor: AppColors.surface),
        );

    return MaterialApp(
      scrollBehavior: const AppScrollBehavior(),
      title: 'AreWeCookin',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLanguages.supportedLocales,
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        return AppLanguages.resolveLocale(deviceLocale);
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: themeFor(Brightness.light),
      darkTheme: themeFor(Brightness.dark),
      themeMode: themeMode,
      builder: (context, child) {
        // Also follow the system when it switches while the app is open.
        MediaQuery.platformBrightnessOf(context);
        applyThemeToPalette(themeMode);
        return child ?? const SizedBox.shrink();
      },
      // Always start on the splash screen; a shared link (#/recipe/ID) is opened from there.
      // Flutter would split a shared link (/recipe/ID) into several initial routes; always start on one splash.
      onGenerateInitialRoutes: (_) => [
        MaterialPageRoute<void>(builder: (_) => const SplashScreen(), settings: const RouteSettings(name: '/')),
      ],
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        builder: (_) => const SplashScreen(),
        settings: settings,
      ),
    );
  }
}


