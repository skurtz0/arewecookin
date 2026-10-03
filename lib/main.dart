import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/locale_provider.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

    return MaterialApp(
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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5722), // Warm culinary orange
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}


