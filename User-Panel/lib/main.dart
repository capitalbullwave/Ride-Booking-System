import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wavego_user/core/routes/app_router.dart';
import 'package:wavego_user/core/storage/local_storage_service.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_theme.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/services/push_notification_service.dart';
import 'package:wavego_user/widgets/common/phone_mode_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
    ),
  );

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const WaveGoUserApp(),
    ),
  );
}

class WaveGoUserApp extends ConsumerStatefulWidget {
  const WaveGoUserApp({super.key});

  @override
  ConsumerState<WaveGoUserApp> createState() => _WaveGoUserAppState();
}

class _WaveGoUserAppState extends ConsumerState<WaveGoUserApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final push = ref.read(pushNotificationServiceProvider);
      final router = ref.read(routerProvider);
      push.onNavigate = (data) {
        PushNotificationService.navigateFromPayload(router.go, data);
      };
      await push.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final isDark = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Bull Wave Rides',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      builder: (context, child) => PhoneModeShell(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
