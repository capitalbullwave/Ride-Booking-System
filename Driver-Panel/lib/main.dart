import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/routes/app_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/core/storage/local_storage_service.dart';
import 'package:wavego_driver/core/storage/secure_storage_service.dart';
import 'package:wavego_driver/core/theme/app_theme.dart';
import 'package:wavego_driver/providers/auth_session_provider.dart';
import 'package:wavego_driver/providers/ride_provider.dart';
import 'package:wavego_driver/providers/settings_provider.dart';
import 'package:wavego_driver/services/push_notification_service.dart';
import 'package:wavego_driver/widgets/common/connectivity_banner.dart';
import 'package:wavego_driver/widgets/common/phone_mode_shell.dart';

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
  final secureStorage = SecureStorageService();
  final authTokenStore = AuthTokenStore(secureStorage, sharedPreferences);
  await authTokenStore.hydrate();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        authTokenStoreProvider.overrideWithValue(authTokenStore),
      ],
      child: const WaveGoDriverApp(),
    ),
  );
}

class WaveGoDriverApp extends ConsumerStatefulWidget {
  const WaveGoDriverApp({super.key});

  @override
  ConsumerState<WaveGoDriverApp> createState() => _WaveGoDriverAppState();
}

class _WaveGoDriverAppState extends ConsumerState<WaveGoDriverApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      hydrateAppPreferences(ref);
      await ref.read(authSessionProvider.notifier).refresh();

      final push = ref.read(pushNotificationServiceProvider);
      final router = ref.read(routerProvider);
      push.onNavigate = (data) {
        PushNotificationService.navigateFromPayload(router.go, data);
      };
      await push.initialize();
      if (ref.read(authSessionProvider)) {
        await push.syncTokenToBackend();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final isDark = ref.watch(themeModeProvider);

    ref.listen<bool>(authSessionProvider, (previous, next) {
      if (previous == true && next == false) {
        router.go(RouteNames.phoneLogin);
      }
      if (previous != true && next == true) {
        ref.read(pushNotificationServiceProvider).syncTokenToBackend();
      }
    });

    ref.listen(rideViewModelProvider.select((s) => s.activeRide?.id), (prev, next) {
      if (next == null || next.isEmpty) return;
      final location = router.state.matchedLocation;
      if (location != RouteNames.activeTrip) {
        router.go(RouteNames.activeTrip);
      }
    });

    return MaterialApp.router(
      title: 'Bull Wave Rides Captain',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      builder: (context, child) => PhoneModeShell(
        child: ConnectivityBanner(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
